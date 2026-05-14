from __future__ import annotations

import sys
from collections.abc import Iterable
from dataclasses import dataclass
from typing import NamedTuple

from pycircuit import (
    CycleAwareCircuit,
    CycleAwareDomain,
    cas,
    compile_cycle_aware,
    u,
    wire_of,
)

DATA_WIDTH = 8
DEPTH = 2


class FifoOutputs(NamedTuple):
    wready: int
    rvalid: int
    rdata: int
    depth: int
    full: int
    empty: int
    write_fire: int
    read_fire: int
    overflow: int
    underflow: int


@dataclass(frozen=True)
class FifoState:
    values: tuple[int, ...] = ()

    def __post_init__(self) -> None:
        if len(self.values) > DEPTH:
            raise ValueError("ready/valid FIFO reference state exceeds depth")
        for value in self.values:
            if not 0 <= int(value) < (1 << DATA_WIDTH):
                raise ValueError("ready/valid FIFO reference data must fit DATA_WIDTH")


@dataclass(frozen=True)
class FifoCycle:
    wvalid: int = 0
    wdata: int = 0
    rready: int = 0
    clear: int = 0


def step_reference(
    state: FifoState,
    cycle: FifoCycle,
    *,
    pass_through: bool = True,
) -> tuple[FifoOutputs, FifoState]:
    """Executable spec for the tiny independently written FIFO example."""

    values = list(state.values)
    depth = len(values)
    clear = 1 if cycle.clear else 0
    wvalid = 1 if cycle.wvalid else 0
    rready = 1 if cycle.rready else 0
    wdata = int(cycle.wdata) & ((1 << DATA_WIDTH) - 1)

    visible_depth = 0 if clear else depth
    empty = 1 if visible_depth == 0 else 0
    full = 1 if visible_depth == DEPTH else 0
    pass_read = bool(pass_through and empty and wvalid)
    rvalid = 0 if clear else int((not empty) or pass_read)
    rdata = wdata if pass_read else (values[0] if values and not clear else 0)
    wready = 0 if clear else int((not full) or (bool(rready) and bool(rvalid)))

    write_fire = int(bool(wvalid) and bool(wready) and not clear)
    read_fire = int(bool(rready) and bool(rvalid) and not clear)
    overflow = int(bool(wvalid) and not bool(wready) and not clear)
    underflow = int(bool(rready) and not bool(rvalid) and not clear)

    next_values = [] if clear else list(values)
    if not clear:
        if read_fire and next_values:
            next_values.pop(0)
        # Empty pass-through read consumes the write in the same cycle; do not store it.
        if write_fire and not (pass_read and read_fire):
            if len(next_values) < DEPTH:
                next_values.append(wdata)

    outputs = FifoOutputs(
        wready=wready,
        rvalid=rvalid,
        rdata=rdata,
        depth=visible_depth,
        full=full,
        empty=empty,
        write_fire=write_fire,
        read_fire=read_fire,
        overflow=overflow,
        underflow=underflow,
    )
    return outputs, FifoState(tuple(next_values))


def simulate_reference(
    cycles: Iterable[FifoCycle],
    *,
    pass_through: bool = True,
) -> tuple[list[FifoOutputs], FifoState]:
    state = FifoState()
    outputs: list[FifoOutputs] = []
    for cycle in cycles:
        output, state = step_reference(state, cycle, pass_through=pass_through)
        outputs.append(output)
    return outputs, state


def build(
    m: CycleAwareCircuit,
    domain: CycleAwareDomain,
    *,
    pass_through: bool = True,
) -> None:
    """Build a small V5 ready/valid FIFO fixture with observable status outputs.

    This example intentionally avoids a public helper API and compiler changes: it is
    handwritten from existing V5 state signals so reset, clear, simultaneous
    push/pop, optional empty pass-through, and debug names are visible in MLIR.
    """

    wvalid = cas(domain, m.input("wvalid", width=1), cycle=0)
    wdata = cas(domain, m.input("wdata", width=DATA_WIDTH), cycle=0)
    rready = cas(domain, m.input("rready", width=1), cycle=0)
    clear = cas(domain, m.input("clear", width=1), cycle=0)

    data0 = domain.signal(width=DATA_WIDTH, reset_value=0, name="rvfifo_data0")
    data1 = domain.signal(width=DATA_WIDTH, reset_value=0, name="rvfifo_data1")
    count = domain.signal(width=2, reset_value=0, name="rvfifo_count")

    zero2 = u(2, 0)
    one2 = u(2, 1)
    depth2 = u(2, DEPTH)
    zero_data = u(DATA_WIDTH, 0)
    pass_enable = u(1, 1 if pass_through else 0)

    raw_empty = count == zero2
    empty = clear | raw_empty
    full = (~clear) & (count == depth2)
    pass_read = pass_enable & raw_empty & wvalid
    rvalid = (~clear) & ((~raw_empty) | pass_read)
    rdata = wdata if pass_read else (zero_data if (raw_empty | clear) else data0)
    wready = (~clear) & ((~full) | (rready & rvalid))

    write_fire = wvalid & wready
    read_fire = rready & rvalid
    overflow = wvalid & (~wready) & (~clear)
    underflow = rready & (~rvalid) & (~clear)

    m.output("wready", wire_of(wready))
    m.output("rvalid", wire_of(rvalid))
    m.output("rdata", wire_of(rdata))
    m.output("depth", wire_of(zero2 if clear else count))
    m.output("full", wire_of(full))
    m.output("empty", wire_of(empty))
    m.output("write_fire", wire_of(write_fire))
    m.output("read_fire", wire_of(read_fire))
    m.output("overflow", wire_of(overflow))
    m.output("underflow", wire_of(underflow))

    domain.next()

    push_only = write_fire & (~read_fire)
    pop_only = read_fire & (~write_fire)
    pass_consumed = pass_read & read_fire
    count_inc = (count + one2)[0:2]
    count_dec = (count - one2)[0:2]
    next_count = (
        zero2
        if clear
        else (count_inc if push_only else (count_dec if pop_only else count))
    )

    count_is_zero = count == zero2
    count_is_one = count == one2
    count_is_two = count == depth2

    pushed_empty = write_fire & count_is_zero & (~pass_consumed)
    simultaneous_count_one = write_fire & count_is_one
    simultaneous_count_two = write_fire & count_is_two

    pop_data0 = (
        wdata
        if simultaneous_count_one
        else (data1 if simultaneous_count_two else data0)
    )
    hold_or_push_data0 = wdata if pushed_empty else data0
    next_data0 = (
        zero_data if clear else (pop_data0 if read_fire else hold_or_push_data0)
    )
    next_data1 = (
        zero_data
        if clear
        else (
            wdata
            if (read_fire & write_fire & count_is_two)
            else (wdata if (write_fire & count_is_one & (~read_fire)) else data1)
        )
    )

    data0 <<= next_data0
    data1 <<= next_data1
    count <<= next_count


build.__pycircuit_name__ = "ready_valid_fifo"


if __name__ == "__main__":
    sys.stdout.write(compile_cycle_aware(build, name="ready_valid_fifo").emit_mlir())
    sys.stdout.write("\n")
