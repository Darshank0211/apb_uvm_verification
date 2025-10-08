vlog -work work -vopt -sv -stats=none +cover=bcesft C:/Users/apb_uvm_uvm/top.svh
vsim -coverage -assertdebug -voptargs=+acc work.apb_tb_top -l log.txt
add wave -position insertpoint sim:/apb_tb_top/intf/*
run -all
coverage report -cvg -details
coverage report -codeAll
coverage report -assert -details
coverage save -onexit apb_coverage_with_assert.ucdb


