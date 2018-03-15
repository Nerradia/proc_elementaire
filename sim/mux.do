add wave -position insertpoint  \
sim:/mux/sel \
sim:/mux/data_0 \
sim:/mux/data_1 \
sim:/mux/data_out
force -freeze sim:/mux/sel 0 0, 1 200
force -freeze sim:/mux/data_0 "000000" 0
force -freeze sim:/mux/data_1 "101010" 0
run 400