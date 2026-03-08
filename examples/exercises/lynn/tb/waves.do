# coremark_waves.do
add wave sim:/testbench/dut/ieu/dp/SizedResult
add wave sim:/testbench/dut/ieu/dp/PC
add wave sim:/testbench/dut/prv/csrf/rdcycle
add wave sim:/testbench/dut/prv/csrf/rdtime
add wave sim:/testbench/dut/prv/csrf/rdinsret
run -all
view wave
