add wave -position insertpoint  \
sim:/reg/reset
add wave -position insertpoint  \
sim:/reg/clk
add wave -position insertpoint  \
sim:/reg/clk_en
add wave -position insertpoint  \
sim:/reg/load
add wave -position insertpoint  \
sim:/reg/init
add wave -position insertpoint  \
sim:/reg/data_in
add wave -position insertpoint  \
sim:/reg/data_out

force -freeze sim:/reg/reset 1 0, 0 100

force -freeze sim:/reg/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/reg/clk_en 1 0

force -freeze sim:/reg/load 0 0, 1 300, 0 400
force -freeze sim:/reg/data_in "00000001" 0, "00000010" 100, "00000011" 200, "00000100" 300, "00000101" 400, "00000110" 500, "00000111" 600, "00001000" 700, "00001001" 800, "00001010" 900

force -freeze sim:/reg/init 0 0, 1 600, 0 700