from __future__ import annotations

import sys
from pathlib import Path

import pycircuit
import pytest

pytestmark = pytest.mark.unit

_EXAMPLE_DIR = (
    Path(__file__).resolve().parents[2] / "designs" / "examples" / "fifo_loopback"
)
if str(_EXAMPLE_DIR) not in sys.path:
    sys.path.insert(0, str(_EXAMPLE_DIR))

from ready_valid_fifo import (  # noqa: E402
    FifoCycle,
    FifoState,
    build,
    simulate_reference,
    step_reference,
)


def test_reference_reset_clear_push_pop_and_status_trace() -> None:
    outputs, state = simulate_reference(
        [
            FifoCycle(wvalid=1, wdata=0x11),
            FifoCycle(wvalid=1, wdata=0x22),
            FifoCycle(wvalid=1, wdata=0x33),
            FifoCycle(rready=1),
            FifoCycle(wvalid=1, wdata=0x44, rready=1),
            FifoCycle(clear=1, wvalid=1, wdata=0x55, rready=1),
            FifoCycle(),
        ]
    )

    assert outputs[0] == (
        1,  # wready accepts the first write
        1,  # rvalid reflects deterministic empty pass-through visibility
        0x11,
        0,
        0,
        1,
        1,
        0,
        0,
        0,
    )
    assert outputs[1].rvalid == 1
    assert outputs[1].rdata == 0x11
    assert outputs[1].depth == 1
    assert outputs[2].full == 1
    assert outputs[2].wready == 0
    assert outputs[2].overflow == 1
    assert outputs[3].read_fire == 1
    assert outputs[3].rdata == 0x11
    assert outputs[4].read_fire == 1
    assert outputs[4].write_fire == 1
    assert outputs[4].rdata == 0x22
    assert outputs[5].depth == 0
    assert outputs[5].empty == 1
    assert outputs[5].write_fire == 0
    assert outputs[5].read_fire == 0
    assert outputs[6].empty == 1
    assert state == FifoState()


def test_empty_pass_through_enabled_and_disabled_are_explicit() -> None:
    pass_output, pass_state = step_reference(
        FifoState(), FifoCycle(wvalid=1, wdata=0xA5, rready=1), pass_through=True
    )
    assert pass_output.rvalid == 1
    assert pass_output.rdata == 0xA5
    assert pass_output.write_fire == 1
    assert pass_output.read_fire == 1
    assert pass_output.underflow == 0
    assert pass_state == FifoState()

    strict_output, strict_state = step_reference(
        FifoState(), FifoCycle(wvalid=1, wdata=0xA5, rready=1), pass_through=False
    )
    assert strict_output.rvalid == 0
    assert strict_output.write_fire == 1
    assert strict_output.read_fire == 0
    assert strict_output.underflow == 1
    assert strict_state == FifoState((0xA5,))


def test_v5_fifo_fixture_compiles_with_stable_debug_names() -> None:
    design = pycircuit.compile_cycle_aware(build, name="ready_valid_fifo")
    mlir = design.emit_mlir()

    for name in [
        "wvalid",
        "wdata",
        "rready",
        "clear",
        "wready",
        "rvalid",
        "rdata",
        "depth",
        "full",
        "empty",
        "overflow",
        "underflow",
        "rvfifo_data0",
        "rvfifo_data1",
        "rvfifo_count",
    ]:
        assert name in mlir
    assert "pyc.fifo" not in mlir
