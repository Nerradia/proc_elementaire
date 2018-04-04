force -freeze sim:/top_cpu/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/top_cpu/clk_en 1 0
force -freeze sim:/top_cpu/reset 1 0
force -freeze sim:/top_cpu/reset 1 0, 0 200