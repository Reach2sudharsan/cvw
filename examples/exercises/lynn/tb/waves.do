# coremark_waves.do
add wave sim:/testbench/dut/ieu/dp/WriteData
add wave sim:/testbench/dut/ieu/dp/SrcA
add wave sim:/testbench/dut/ieu/dp/SrcB
add wave sim:/testbench/dut/ieu/dp/PC
add wave sim:/testbench/dut/ieu/dp/IEUAdr
add wave sim:/testbench/dut/ieu/dp/ALUControl
add wave sim:/testbench/dut/ieu/MemEn
run -all
view wave
