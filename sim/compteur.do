add wave -position insertpoint  \
sim:/compteur/reset \
sim:/compteur/clk \
sim:/compteur/clk_en \
sim:/compteur/init_cpt \
sim:/compteur/en_cpt \
sim:/compteur/load_cpt \
sim:/compteur/cpt_in \
sim:/compteur/cpt_out \
sim:/compteur/cpt

force -freeze reset 1 0, 0 100
force -freeze sim:/compteur/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/compteur/clk_en 1 0
force -freeze sim:/compteur/cpt_in 000000 0
force -freeze sim:/compteur/en_cpt 0 0
force -freeze sim:/compteur/init_cpt 0 0

force -freeze sim:/compteur/en_cpt 0 0, 1 100, 0 200 -repeat 400
force -freeze sim:/compteur/en_cpt 0 100

force -freeze sim:/compteur/cpt_in 011000 4000
force -freeze sim:/compteur/load_cpt 0 0, 1 4100, 0 4200

force -freeze sim:/compteur/init_cpt 1 6000, 0 6100