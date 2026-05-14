from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, NamedTuple

from pycircuit import CycleAwareCircuit, CycleAwareDomain, cas, compile_cycle_aware, mux, wire_of

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


def _in(
    inputs: dict[str, object] | None,
    key: str,
    m: CycleAwareCircuit,
    domain: CycleAwareDomain,
    width: int,
):
    if inputs is not None and key in inputs:
        return inputs[key]
    return cas(domain, m.input(key, width=width), cycle=0)


def build(
    m: CycleAwareCircuit,
    domain: CycleAwareDomain,
    *,
    inputs: dict[str, object] | None = None,
    pass_through: bool = True,
) -> dict[str, object]:
    """Build a small V5 ready/valid FIFO fixture with observable status outputs.

    This example intentionally avoids a public helper API and compiler changes: it is
    handwritten from existing V5 state signals so reset, clear, simultaneous
    push/pop, optional empty pass-through, and debug names are visible in MLIR.
    """

    wvalid = _in(inputs, "wvalid", m, domain, 1)
    wdata = _in(inputs, "wdata", m, domain, DATA_WIDTH)
    rready = _in(inputs, "rready", m, domain, 1)
    clear = _in(inputs, "clear", m, domain, 1)

    data0 = domain.signal(width=DATA_WIDTH, reset_value=0, name="rvfifo_data0")
    data1 = domain.signal(width=DATA_WIDTH, reset_value=0, name="rvfifo_data1")
    count = domain.signal(width=2, reset_value=0, name="rvfifo_count")

    zero1 = cas(domain, m.const(0, width=1), cycle=0)
    one1 = cas(domain, m.const(1, width=1), cycle=0)
    zero2 = cas(domain, m.const(0, width=2), cycle=0)
    one2 = cas(domain, m.const(1, width=2), cycle=0)
    depth2 = cas(domain, m.const(DEPTH, width=2), cycle=0)
    zero_data = cas(domain, m.const(0, width=DATA_WIDTH), cycle=0)
    pass_enable = cas(domain, m.const(1 if pass_through else 0, width=1), cycle=0)

    raw_empty = count == zero2
    empty = clear | raw_empty
    full = (~clear) & (count == depth2)
    pass_read = pass_enable & raw_empty & wvalid
    rvalid = (~clear) & ((~raw_empty) | pass_read)
    rdata = mux(pass_read, wdata, mux(raw_empty | clear, zero_data, data0))
    wready = (~clear) & ((~full) | (rready & rvalid))

    write_fire = wvalid & wready
    read_fire = rready & rvalid
    overflow = wvalid & (~wready) & (~clear)
    underflow = rready & (~rvalid) & (~clear)

    outs: dict[str, object] = {
        "wready": wready,
        "rvalid": rvalid,
        "rdata": rdata,
        "depth": mux(clear, zero2, count),
        "full": full,
        "empty": empty,
        "write_fire": write_fire,
        "read_fire": read_fire,
        "overflow": overflow,
        "underflow": underflow,
    }

    if inputs is None:
        for name, value in outs.items():
            m.output(name, wire_of(value))

    domain.next()

    push_only = write_fire & (~read_fire)
    pop_only = read_fire & (~write_fire)
    pass_consumed = pass_read & read_fire
    count_inc = (count + one2).trunc(2)
    count_dec = (count - one2).trunc(2)
    next_count = mux(clear, zero2, mux(push_only, count_inc, mux(pop_only, count_dec, count)))

    count_is_zero = count == zero2
    count_is_one = count == one2
    count_is_two = count == depth2

    next_data0 = mux(
        clear,
        zero_data,
        mux(
            read_fire,
            mux(write_fire, mux(count_is_one, wdata, mux(count_is_two, data1, data0)), data1),
            mux(write_fire & count_is_zero & (~pass_consumed), wdata, data0),
        ),
    )
    next_data1 = mux(
        clear,
        zero_data,
        mux(read_fire & write_fire & count_is_two, wdata, mux(write_fire & count_is_one & (~read_fire), wdata, data1)),
    )

    data0 <<= next_data0
    data1 <<= next_data1
    count <<= next_count

    return outs


build.__pycircuit_name__ = "ready_valid_fifo"


if __name__ == "__main__":
    print(
        compile_cycle_aware(build, name="ready_valid_fifo", eager=True).emit_mlir()
    )
