from __future__ import annotations

import pytest
from pycircuit import CycleAwareTb, Tb
from pycircuit.cli import _render_tb_cpp, _render_tb_sv, _TopIface

pytestmark = pytest.mark.unit


def _diag_iface() -> _TopIface:
    return _TopIface(
        sym="DiagTop",
        in_raw=[],
        in_tys=[],
        out_raw=["done"],
        out_tys=["i8"],
    )


def test_cycle_aware_expect_records_context_labels_and_msg() -> None:
    t = Tb()
    tb = CycleAwareTb(t)

    with tb.context(lane=2, src="load"):
        tb.expect("done", 3, msg="custom failure", labels={"case": "underflow"})

    expect = t.expects[0]
    assert expect.port == "done"
    assert expect.value == 3
    assert expect.at == 0
    assert expect.phase == "post"
    assert expect.msg == "custom failure"
    assert expect.labels == (
        ("lane", "2"),
        ("src", "load"),
        ("case", "underflow"),
    )


def test_cycle_aware_expect_diagnostics_render_stable_fields() -> None:
    t = Tb()
    tb = CycleAwareTb(t)

    tb.expect(
        "done",
        3,
        phase="pre",
        msg="custom failure",
        labels={"lane": 2, "src": "load"},
    )

    cpp = _render_tb_cpp(_diag_iface(), t)
    sv = _render_tb_sv(_diag_iface(), t)

    for rendered in (cpp, sv):
        assert "port=done" in rendered
        assert "cycle=0" in rendered
        assert "phase=pre" in rendered
        assert "labels={lane=2,src=load}" in rendered
        assert "msg=custom failure" in rendered
        assert "actual=" in rendered
        assert "expected=0x3" in rendered
