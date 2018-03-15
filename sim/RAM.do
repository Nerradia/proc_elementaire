add wave -position insertpoint  \
sim:/ram/clk \
sim:/ram/clk_en \
sim:/ram/R_W \
sim:/ram/address \
sim:/ram/data_in \
sim:/ram/data_out \
sim:/ram/memoire

force -freeze sim:/RAM/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/RAM/clk_en 1 0

force -freeze sim:/RAM/R_W 0 0

force -freeze sim:/RAM/data_in "00000000" 0
force -freeze sim:/RAM/address "000001" 0, "000010" 100, "000011" 200, "000100" 300, "000101" 400, "000110" 500, "000111" 600, "001000" 700

force -freeze sim:/RAM/address "000011" 1000
force -freeze sim:/RAM/data_in "00110011" 1000
force -freeze sim:/RAM/R_W 1 1100, 0 1200