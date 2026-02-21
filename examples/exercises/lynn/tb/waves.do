# coremark_waves.do
add wave sim:/testbench/dut/ieu/dp/WriteData
add wave sim:/testbench/dut/ieu/dp/SrcA
add wave sim:/testbench/dut/ieu/dp/SrcB
add wave sim:/testbench/dut/ieu/dp/Eq
add wave sim:/testbench/dut/ieu/dp/IEUResult
add wave sim:/testbench/dut/ieu/dp/PC
run -all
view wave
