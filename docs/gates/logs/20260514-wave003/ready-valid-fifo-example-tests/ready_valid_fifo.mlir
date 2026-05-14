module {
func.func @ready_valid_fifo(%clk: !pyc.clock, %rst: !pyc.reset, %wvalid: i1, %wdata: i8, %rready: i1, %clear: i1) -> (i1, i1, i8, i2, i1, i1, i1, i1, i1, i1) attributes {arg_names = ["clk", "rst", "wvalid", "wdata", "rready", "clear"], result_names = ["wready", "rvalid", "rdata", "depth", "full", "empty", "write_fire", "read_fire", "overflow", "underflow"]} {
  %v1 = pyc.wire {pyc.name = "rvfifo_data0__next"} : i8
  %v2 = pyc.constant 1 : i1
  %v3 = pyc.constant 0 : i8
  %v4 = pyc.reg %clk, %rst, %v2, %v1, %v3 : i8
  %v5 = pyc.alias %v4 {pyc.name = "rvfifo_data0"} : i8
  %v6 = pyc.wire {pyc.name = "rvfifo_data1__next"} : i8
  %v7 = pyc.constant 1 : i1
  %v8 = pyc.constant 0 : i8
  %v9 = pyc.reg %clk, %rst, %v7, %v6, %v8 : i8
  %v10 = pyc.alias %v9 {pyc.name = "rvfifo_data1"} : i8
  %v11 = pyc.wire {pyc.name = "rvfifo_count__next"} : i2
  %v12 = pyc.constant 1 : i1
  %v13 = pyc.constant 0 : i2
  %v14 = pyc.reg %clk, %rst, %v12, %v11, %v13 : i2
  %v15 = pyc.alias %v14 {pyc.name = "rvfifo_count"} : i2
  %v16 = pyc.constant 0 : i1
  %v17 = pyc.constant 1 : i1
  %v18 = pyc.constant 0 : i2
  %v19 = pyc.constant 1 : i2
  %v20 = pyc.constant 2 : i2
  %v21 = pyc.constant 0 : i8
  %v22 = pyc.constant 1 : i1
  %v23 = pyc.eq %v15, %v18 : i2
  %v24 = pyc.or %clear, %v23 : i1
  %v25 = pyc.not %clear : i1
  %v26 = pyc.eq %v15, %v20 : i2
  %v27 = pyc.and %v25, %v26 : i1
  %v28 = pyc.and %v22, %v23 : i1
  %v29 = pyc.and %v28, %wvalid : i1
  %v30 = pyc.not %clear : i1
  %v31 = pyc.not %v23 : i1
  %v32 = pyc.or %v31, %v29 : i1
  %v33 = pyc.and %v30, %v32 : i1
  %v34 = pyc.or %v23, %clear : i1
  %v35 = pyc.mux %v34, %v21, %v5 : i8
  %v36 = pyc.mux %v29, %wdata, %v35 : i8
  %v37 = pyc.not %clear : i1
  %v38 = pyc.not %v27 : i1
  %v39 = pyc.and %rready, %v33 : i1
  %v40 = pyc.or %v38, %v39 : i1
  %v41 = pyc.and %v37, %v40 : i1
  %v42 = pyc.and %wvalid, %v41 : i1
  %v43 = pyc.and %rready, %v33 : i1
  %v44 = pyc.not %v41 : i1
  %v45 = pyc.and %wvalid, %v44 : i1
  %v46 = pyc.not %clear : i1
  %v47 = pyc.and %v45, %v46 : i1
  %v48 = pyc.not %v33 : i1
  %v49 = pyc.and %rready, %v48 : i1
  %v50 = pyc.not %clear : i1
  %v51 = pyc.and %v49, %v50 : i1
  %v52 = pyc.mux %clear, %v18, %v15 : i2
  %v53 = pyc.not %v43 : i1
  %v54 = pyc.and %v42, %v53 : i1
  %v55 = pyc.not %v42 : i1
  %v56 = pyc.and %v43, %v55 : i1
  %v57 = pyc.and %v29, %v43 : i1
  %v58 = pyc.add %v15, %v19 : i2
  %v59 = pyc.trunc %v58 : i2 -> i2
  %v60 = pyc.sub %v15, %v19 : i2
  %v61 = pyc.trunc %v60 : i2 -> i2
  %v62 = pyc.mux %v56, %v61, %v15 : i2
  %v63 = pyc.mux %v54, %v59, %v62 : i2
  %v64 = pyc.mux %clear, %v18, %v63 : i2
  %v65 = pyc.eq %v15, %v18 : i2
  %v66 = pyc.eq %v15, %v19 : i2
  %v67 = pyc.eq %v15, %v20 : i2
  %v68 = pyc.mux %v67, %v10, %v5 : i8
  %v69 = pyc.mux %v66, %wdata, %v68 : i8
  %v70 = pyc.mux %v42, %v69, %v10 : i8
  %v71 = pyc.and %v42, %v65 : i1
  %v72 = pyc.not %v57 : i1
  %v73 = pyc.and %v71, %v72 : i1
  %v74 = pyc.mux %v73, %wdata, %v5 : i8
  %v75 = pyc.mux %v43, %v70, %v74 : i8
  %v76 = pyc.mux %clear, %v21, %v75 : i8
  %v77 = pyc.and %v43, %v42 : i1
  %v78 = pyc.and %v77, %v67 : i1
  %v79 = pyc.and %v42, %v66 : i1
  %v80 = pyc.not %v43 : i1
  %v81 = pyc.and %v79, %v80 : i1
  %v82 = pyc.mux %v81, %wdata, %v10 : i8
  %v83 = pyc.mux %v78, %wdata, %v82 : i8
  %v84 = pyc.mux %clear, %v21, %v83 : i8
  pyc.assign %v1, %v76 : i8
  pyc.assign %v6, %v84 : i8
  pyc.assign %v11, %v64 : i2
  func.return %v41, %v33, %v36, %v52, %v27, %v24, %v42, %v43, %v47, %v51 : i1, i1, i8, i2, i1, i1, i1, i1, i1, i1
}
}

