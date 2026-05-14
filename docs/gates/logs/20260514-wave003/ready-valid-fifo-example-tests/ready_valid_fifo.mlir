module attributes {pyc.top = @ready_valid_fifo, pyc.frontend.contract = "pycircuit"} {
func.func @ready_valid_fifo(%clk: !pyc.clock, %rst: !pyc.reset, %wvalid: i1, %wdata: i8, %rready: i1, %clear: i1) -> (i1, i1, i8, i2, i1, i1, i1, i1, i1, i1) attributes {arg_names = ["clk", "rst", "wvalid", "wdata", "rready", "clear"], result_names = ["wready", "rvalid", "rdata", "depth", "full", "empty", "write_fire", "read_fire", "overflow", "underflow"], pyc.base = "ready_valid_fifo", pyc.params = "{\"pass_through\":true}", pyc.kind = "module", pyc.inline = "false", pyc.value_params = [], pyc.value_param_types = [], pyc.struct.metrics = "{\"ast_node_count\":705,\"collection_count\":0,\"collection_instance_count\":0,\"estimated_inline_cost\":204,\"hardware_call_count\":15,\"instance_count\":0,\"loop_count\":0,\"module_call_count\":0,\"module_family_collection_count\":0,\"repeat_pressure\":0,\"repeated_body_clusters\":[],\"source_loc\":56,\"state_alloc_count\":24,\"state_call_count\":0}", pyc.struct.collections = "[]"} {
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
  %v16 = pyc.constant 0 : i2
  %v17 = pyc.eq %v15, %v16 : i2
  %v18 = pyc.or %clear, %v17 : i1
  %v19 = pyc.not %clear : i1
  %v20 = pyc.constant 2 : i2
  %v21 = pyc.eq %v15, %v20 : i2
  %v22 = pyc.and %v21, %v19 : i1
  %v23 = pyc.constant 1 : i1
  %v24 = pyc.and %v17, %v23 : i1
  %v25 = pyc.and %v24, %wvalid : i1
  %v26 = pyc.not %clear : i1
  %v27 = pyc.not %v17 : i1
  %v28 = pyc.or %v25, %v27 : i1
  %v29 = pyc.and %v28, %v26 : i1
  %v30 = pyc.or %v17, %clear : i1
  %v31 = pyc.constant 0 : i8
  %v32 = pyc.mux %v30, %v31, %v5 : i8
  %v33 = pyc.mux %v25, %wdata, %v32 : i8
  %v34 = pyc.not %clear : i1
  %v35 = pyc.not %v22 : i1
  %v36 = pyc.and %rready, %v29 : i1
  %v37 = pyc.or %v36, %v35 : i1
  %v38 = pyc.and %v37, %v34 : i1
  %v39 = pyc.and %wvalid, %v38 : i1
  %v40 = pyc.and %rready, %v29 : i1
  %v41 = pyc.not %v38 : i1
  %v42 = pyc.and %wvalid, %v41 : i1
  %v43 = pyc.not %clear : i1
  %v44 = pyc.and %v42, %v43 : i1
  %v45 = pyc.not %v29 : i1
  %v46 = pyc.and %rready, %v45 : i1
  %v47 = pyc.not %clear : i1
  %v48 = pyc.and %v46, %v47 : i1
  %v49 = pyc.constant 0 : i2
  %v50 = pyc.mux %clear, %v49, %v15 : i2
  %v51 = pyc.not %v40 : i1
  %v52 = pyc.wire {pyc.name = "_v5_bal_1__next"} : i1
  %v53 = pyc.constant 1 : i1
  %v54 = pyc.constant 0 : i1
  %v55 = pyc.reg %clk, %rst, %v53, %v52, %v54 : i1
  %v56 = pyc.alias %v55 {pyc.name = "_v5_bal_1"} : i1
  pyc.assign %v52, %v39 : i1
  %v57 = pyc.and %v56, %v51 : i1
  %v58 = pyc.not %v39 : i1
  %v59 = pyc.wire {pyc.name = "_v5_bal_2__next"} : i1
  %v60 = pyc.constant 1 : i1
  %v61 = pyc.constant 0 : i1
  %v62 = pyc.reg %clk, %rst, %v60, %v59, %v61 : i1
  %v63 = pyc.alias %v62 {pyc.name = "_v5_bal_2"} : i1
  pyc.assign %v59, %v40 : i1
  %v64 = pyc.and %v63, %v58 : i1
  %v65 = pyc.and %v25, %v40 : i1
  %v66 = pyc.constant 1 : i2
  %v67 = pyc.wire {pyc.name = "_v5_bal_3__next"} : i2
  %v68 = pyc.constant 1 : i1
  %v69 = pyc.constant 0 : i2
  %v70 = pyc.reg %clk, %rst, %v68, %v67, %v69 : i2
  %v71 = pyc.alias %v70 {pyc.name = "_v5_bal_3"} : i2
  pyc.assign %v67, %v15 : i2
  %v72 = pyc.add %v71, %v66 : i2
  %v73 = pyc.extract %v72 {lsb = 0} : i2 -> i2
  %v74 = pyc.constant 1 : i2
  %v75 = pyc.wire {pyc.name = "_v5_bal_4__next"} : i2
  %v76 = pyc.constant 1 : i1
  %v77 = pyc.constant 0 : i2
  %v78 = pyc.reg %clk, %rst, %v76, %v75, %v77 : i2
  %v79 = pyc.alias %v78 {pyc.name = "_v5_bal_4"} : i2
  pyc.assign %v75, %v15 : i2
  %v80 = pyc.sub %v79, %v74 : i2
  %v81 = pyc.extract %v80 {lsb = 0} : i2 -> i2
  %v82 = pyc.wire {pyc.name = "_v5_bal_5__next"} : i2
  %v83 = pyc.constant 1 : i1
  %v84 = pyc.constant 0 : i2
  %v85 = pyc.reg %clk, %rst, %v83, %v82, %v84 : i2
  %v86 = pyc.alias %v85 {pyc.name = "_v5_bal_5"} : i2
  pyc.assign %v82, %v15 : i2
  %v87 = pyc.mux %v64, %v81, %v86 : i2
  %v88 = pyc.mux %v57, %v73, %v87 : i2
  %v89 = pyc.constant 0 : i2
  %v90 = pyc.mux %clear, %v89, %v88 : i2
  %v91 = pyc.constant 0 : i2
  %v92 = pyc.wire {pyc.name = "_v5_bal_6__next"} : i2
  %v93 = pyc.constant 1 : i1
  %v94 = pyc.constant 0 : i2
  %v95 = pyc.reg %clk, %rst, %v93, %v92, %v94 : i2
  %v96 = pyc.alias %v95 {pyc.name = "_v5_bal_6"} : i2
  pyc.assign %v92, %v15 : i2
  %v97 = pyc.eq %v96, %v91 : i2
  %v98 = pyc.constant 1 : i2
  %v99 = pyc.wire {pyc.name = "_v5_bal_7__next"} : i2
  %v100 = pyc.constant 1 : i1
  %v101 = pyc.constant 0 : i2
  %v102 = pyc.reg %clk, %rst, %v100, %v99, %v101 : i2
  %v103 = pyc.alias %v102 {pyc.name = "_v5_bal_7"} : i2
  pyc.assign %v99, %v15 : i2
  %v104 = pyc.eq %v103, %v98 : i2
  %v105 = pyc.constant 2 : i2
  %v106 = pyc.wire {pyc.name = "_v5_bal_8__next"} : i2
  %v107 = pyc.constant 1 : i1
  %v108 = pyc.constant 0 : i2
  %v109 = pyc.reg %clk, %rst, %v107, %v106, %v108 : i2
  %v110 = pyc.alias %v109 {pyc.name = "_v5_bal_8"} : i2
  pyc.assign %v106, %v15 : i2
  %v111 = pyc.eq %v110, %v105 : i2
  %v112 = pyc.wire {pyc.name = "_v5_bal_9__next"} : i1
  %v113 = pyc.constant 1 : i1
  %v114 = pyc.constant 0 : i1
  %v115 = pyc.reg %clk, %rst, %v113, %v112, %v114 : i1
  %v116 = pyc.alias %v115 {pyc.name = "_v5_bal_9"} : i1
  pyc.assign %v112, %v39 : i1
  %v117 = pyc.and %v116, %v97 : i1
  %v118 = pyc.not %v65 : i1
  %v119 = pyc.and %v117, %v118 : i1
  %v120 = pyc.wire {pyc.name = "_v5_bal_10__next"} : i1
  %v121 = pyc.constant 1 : i1
  %v122 = pyc.constant 0 : i1
  %v123 = pyc.reg %clk, %rst, %v121, %v120, %v122 : i1
  %v124 = pyc.alias %v123 {pyc.name = "_v5_bal_10"} : i1
  pyc.assign %v120, %v39 : i1
  %v125 = pyc.and %v124, %v104 : i1
  %v126 = pyc.wire {pyc.name = "_v5_bal_11__next"} : i1
  %v127 = pyc.constant 1 : i1
  %v128 = pyc.constant 0 : i1
  %v129 = pyc.reg %clk, %rst, %v127, %v126, %v128 : i1
  %v130 = pyc.alias %v129 {pyc.name = "_v5_bal_11"} : i1
  pyc.assign %v126, %v39 : i1
  %v131 = pyc.and %v130, %v111 : i1
  %v132 = pyc.wire {pyc.name = "_v5_bal_12__next"} : i8
  %v133 = pyc.constant 1 : i1
  %v134 = pyc.constant 0 : i8
  %v135 = pyc.reg %clk, %rst, %v133, %v132, %v134 : i8
  %v136 = pyc.alias %v135 {pyc.name = "_v5_bal_12"} : i8
  pyc.assign %v132, %v10 : i8
  %v137 = pyc.wire {pyc.name = "_v5_bal_13__next"} : i8
  %v138 = pyc.constant 1 : i1
  %v139 = pyc.constant 0 : i8
  %v140 = pyc.reg %clk, %rst, %v138, %v137, %v139 : i8
  %v141 = pyc.alias %v140 {pyc.name = "_v5_bal_13"} : i8
  pyc.assign %v137, %v5 : i8
  %v142 = pyc.mux %v131, %v136, %v141 : i8
  %v143 = pyc.wire {pyc.name = "_v5_bal_14__next"} : i8
  %v144 = pyc.constant 1 : i1
  %v145 = pyc.constant 0 : i8
  %v146 = pyc.reg %clk, %rst, %v144, %v143, %v145 : i8
  %v147 = pyc.alias %v146 {pyc.name = "_v5_bal_14"} : i8
  pyc.assign %v143, %wdata : i8
  %v148 = pyc.mux %v125, %v147, %v142 : i8
  %v149 = pyc.wire {pyc.name = "_v5_bal_15__next"} : i8
  %v150 = pyc.constant 1 : i1
  %v151 = pyc.constant 0 : i8
  %v152 = pyc.reg %clk, %rst, %v150, %v149, %v151 : i8
  %v153 = pyc.alias %v152 {pyc.name = "_v5_bal_15"} : i8
  pyc.assign %v149, %wdata : i8
  %v154 = pyc.wire {pyc.name = "_v5_bal_16__next"} : i8
  %v155 = pyc.constant 1 : i1
  %v156 = pyc.constant 0 : i8
  %v157 = pyc.reg %clk, %rst, %v155, %v154, %v156 : i8
  %v158 = pyc.alias %v157 {pyc.name = "_v5_bal_16"} : i8
  pyc.assign %v154, %v5 : i8
  %v159 = pyc.mux %v119, %v153, %v158 : i8
  %v160 = pyc.mux %v40, %v148, %v159 : i8
  %v161 = pyc.constant 0 : i8
  %v162 = pyc.mux %clear, %v161, %v160 : i8
  %v163 = pyc.and %v40, %v39 : i1
  %v164 = pyc.wire {pyc.name = "_v5_bal_17__next"} : i1
  %v165 = pyc.constant 1 : i1
  %v166 = pyc.constant 0 : i1
  %v167 = pyc.reg %clk, %rst, %v165, %v164, %v166 : i1
  %v168 = pyc.alias %v167 {pyc.name = "_v5_bal_17"} : i1
  pyc.assign %v164, %v163 : i1
  %v169 = pyc.and %v168, %v111 : i1
  %v170 = pyc.wire {pyc.name = "_v5_bal_18__next"} : i1
  %v171 = pyc.constant 1 : i1
  %v172 = pyc.constant 0 : i1
  %v173 = pyc.reg %clk, %rst, %v171, %v170, %v172 : i1
  %v174 = pyc.alias %v173 {pyc.name = "_v5_bal_18"} : i1
  pyc.assign %v170, %v39 : i1
  %v175 = pyc.and %v174, %v104 : i1
  %v176 = pyc.not %v40 : i1
  %v177 = pyc.and %v175, %v176 : i1
  %v178 = pyc.wire {pyc.name = "_v5_bal_19__next"} : i8
  %v179 = pyc.constant 1 : i1
  %v180 = pyc.constant 0 : i8
  %v181 = pyc.reg %clk, %rst, %v179, %v178, %v180 : i8
  %v182 = pyc.alias %v181 {pyc.name = "_v5_bal_19"} : i8
  pyc.assign %v178, %wdata : i8
  %v183 = pyc.wire {pyc.name = "_v5_bal_20__next"} : i8
  %v184 = pyc.constant 1 : i1
  %v185 = pyc.constant 0 : i8
  %v186 = pyc.reg %clk, %rst, %v184, %v183, %v185 : i8
  %v187 = pyc.alias %v186 {pyc.name = "_v5_bal_20"} : i8
  pyc.assign %v183, %v10 : i8
  %v188 = pyc.mux %v177, %v182, %v187 : i8
  %v189 = pyc.wire {pyc.name = "_v5_bal_21__next"} : i8
  %v190 = pyc.constant 1 : i1
  %v191 = pyc.constant 0 : i8
  %v192 = pyc.reg %clk, %rst, %v190, %v189, %v191 : i8
  %v193 = pyc.alias %v192 {pyc.name = "_v5_bal_21"} : i8
  pyc.assign %v189, %wdata : i8
  %v194 = pyc.mux %v169, %v193, %v188 : i8
  %v195 = pyc.constant 0 : i8
  %v196 = pyc.mux %clear, %v195, %v194 : i8
  pyc.assign %v1, %v162 : i8
  pyc.assign %v6, %v196 : i8
  pyc.assign %v11, %v90 : i2
  func.return %v38, %v29, %v33, %v50, %v22, %v18, %v39, %v40, %v44, %v48 : i1, i1, i8, i2, i1, i1, i1, i1, i1, i1
}

}
