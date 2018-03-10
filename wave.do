onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /top_cpu/clk
add wave -noupdate /top_cpu/clk_en
add wave -noupdate /top_cpu/inst_uc/inst_fsm/state
add wave -noupdate /top_cpu/op_code_size
add wave -noupdate /top_cpu/sel_ual_size
add wave -noupdate /top_cpu/data_size
add wave -noupdate /top_cpu/address_size
add wave -noupdate /top_cpu/reset
add wave -noupdate -radix hexadecimal -childformat {{/top_cpu/address(5) -radix hexadecimal} {/top_cpu/address(4) -radix hexadecimal} {/top_cpu/address(3) -radix hexadecimal} {/top_cpu/address(2) -radix hexadecimal} {/top_cpu/address(1) -radix hexadecimal} {/top_cpu/address(0) -radix hexadecimal}} -subitemconfig {/top_cpu/address(5) {-height 15 -radix hexadecimal} /top_cpu/address(4) {-height 15 -radix hexadecimal} /top_cpu/address(3) {-height 15 -radix hexadecimal} /top_cpu/address(2) {-height 15 -radix hexadecimal} /top_cpu/address(1) {-height 15 -radix hexadecimal} /top_cpu/address(0) {-height 15 -radix hexadecimal}} /top_cpu/address
add wave -noupdate -radix hexadecimal -childformat {{/top_cpu/data_RAM_out(7) -radix hexadecimal} {/top_cpu/data_RAM_out(6) -radix hexadecimal} {/top_cpu/data_RAM_out(5) -radix hexadecimal} {/top_cpu/data_RAM_out(4) -radix hexadecimal} {/top_cpu/data_RAM_out(3) -radix hexadecimal} {/top_cpu/data_RAM_out(2) -radix hexadecimal} {/top_cpu/data_RAM_out(1) -radix hexadecimal} {/top_cpu/data_RAM_out(0) -radix hexadecimal}} -subitemconfig {/top_cpu/data_RAM_out(7) {-height 15 -radix hexadecimal} /top_cpu/data_RAM_out(6) {-height 15 -radix hexadecimal} /top_cpu/data_RAM_out(5) {-height 15 -radix hexadecimal} /top_cpu/data_RAM_out(4) {-height 15 -radix hexadecimal} /top_cpu/data_RAM_out(3) {-height 15 -radix hexadecimal} /top_cpu/data_RAM_out(2) {-height 15 -radix hexadecimal} /top_cpu/data_RAM_out(1) {-height 15 -radix hexadecimal} /top_cpu/data_RAM_out(0) {-height 15 -radix hexadecimal}} /top_cpu/data_RAM_out
add wave -noupdate -radix hexadecimal -childformat {{/top_cpu/data_RAM_in(7) -radix hexadecimal} {/top_cpu/data_RAM_in(6) -radix hexadecimal} {/top_cpu/data_RAM_in(5) -radix hexadecimal} {/top_cpu/data_RAM_in(4) -radix hexadecimal} {/top_cpu/data_RAM_in(3) -radix hexadecimal} {/top_cpu/data_RAM_in(2) -radix hexadecimal} {/top_cpu/data_RAM_in(1) -radix hexadecimal} {/top_cpu/data_RAM_in(0) -radix hexadecimal}} -subitemconfig {/top_cpu/data_RAM_in(7) {-height 15 -radix hexadecimal} /top_cpu/data_RAM_in(6) {-height 15 -radix hexadecimal} /top_cpu/data_RAM_in(5) {-height 15 -radix hexadecimal} /top_cpu/data_RAM_in(4) {-height 15 -radix hexadecimal} /top_cpu/data_RAM_in(3) {-height 15 -radix hexadecimal} /top_cpu/data_RAM_in(2) {-height 15 -radix hexadecimal} /top_cpu/data_RAM_in(1) {-height 15 -radix hexadecimal} /top_cpu/data_RAM_in(0) {-height 15 -radix hexadecimal}} /top_cpu/data_RAM_in
add wave -noupdate /top_cpu/init_ff
add wave -noupdate /top_cpu/load_ff
add wave -noupdate /top_cpu/load_rd
add wave -noupdate /top_cpu/load_ra
add wave -noupdate /top_cpu/sel_ual
add wave -noupdate /top_cpu/carry
add wave -noupdate /top_cpu/en_mem
add wave -noupdate /top_cpu/R_W
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/reset
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/clk
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/clk_en
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/init_cpt
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/en_cpt
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/load_cpt
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/sel_mux
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/init_ff
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/load_ff
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/load_ri
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/load_rd
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/load_ra
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/sel_ual
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/carry
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/en_mem
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/R_W
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/op_code
add wave -noupdate -group FSM /top_cpu/inst_uc/inst_fsm/state
add wave -noupdate -group UC /top_cpu/inst_uc/reset
add wave -noupdate -group UC /top_cpu/inst_uc/clk
add wave -noupdate -group UC /top_cpu/inst_uc/clk_en
add wave -noupdate -group UC -radix hexadecimal /top_cpu/inst_uc/data_in
add wave -noupdate -group UC -radix hexadecimal /top_cpu/inst_uc/address_out
add wave -noupdate -group UC /top_cpu/inst_uc/init_ff
add wave -noupdate -group UC /top_cpu/inst_uc/load_ff
add wave -noupdate -group UC /top_cpu/inst_uc/load_rd
add wave -noupdate -group UC /top_cpu/inst_uc/load_ra
add wave -noupdate -group UC /top_cpu/inst_uc/sel_ual
add wave -noupdate -group UC /top_cpu/inst_uc/carry
add wave -noupdate -group UC /top_cpu/inst_uc/en_mem
add wave -noupdate -group UC /top_cpu/inst_uc/R_W
add wave -noupdate -group UC /top_cpu/inst_uc/load_ri
add wave -noupdate -group UC /top_cpu/inst_uc/sel_mux
add wave -noupdate -group UC /top_cpu/inst_uc/init_cpt
add wave -noupdate -group UC /top_cpu/inst_uc/en_cpt
add wave -noupdate -group UC /top_cpu/inst_uc/load_cpt
add wave -noupdate -group UC -radix hexadecimal /top_cpu/inst_uc/reg_inst_out
add wave -noupdate -group UC -radix hexadecimal /top_cpu/inst_uc/cpt_to_mux
add wave -noupdate -radix hexadecimal -childformat {{/top_cpu/inst_RAM/memoire(0) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(1) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(2) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(3) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4) -radix hexadecimal -childformat {{/top_cpu/inst_RAM/memoire(4)(7) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4)(6) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4)(5) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4)(4) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4)(3) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4)(2) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4)(1) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4)(0) -radix hexadecimal}}} {/top_cpu/inst_RAM/memoire(5) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(6) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(7) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8) -radix hexadecimal -childformat {{/top_cpu/inst_RAM/memoire(8)(7) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8)(6) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8)(5) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8)(4) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8)(3) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8)(2) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8)(1) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8)(0) -radix hexadecimal}}} {/top_cpu/inst_RAM/memoire(9) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(10) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(11) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(12) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(13) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(14) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(15) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(16) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(17) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(18) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(19) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(20) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(21) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(22) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(23) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(24) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(25) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(26) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(27) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(28) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(29) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(30) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(31) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(32) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(33) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(34) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(35) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(36) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(37) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(38) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(39) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(40) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(41) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(42) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(43) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(44) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(45) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(46) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(47) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(48) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(49) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(50) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(51) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(52) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(53) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(54) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(55) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(56) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(57) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(58) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(59) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(60) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(61) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(62) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(63) -radix hexadecimal}} -subitemconfig {/top_cpu/inst_RAM/memoire(0) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(1) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(2) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(3) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(4) {-height 15 -radix hexadecimal -childformat {{/top_cpu/inst_RAM/memoire(4)(7) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4)(6) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4)(5) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4)(4) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4)(3) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4)(2) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4)(1) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(4)(0) -radix hexadecimal}}} /top_cpu/inst_RAM/memoire(4)(7) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(4)(6) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(4)(5) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(4)(4) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(4)(3) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(4)(2) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(4)(1) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(4)(0) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(5) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(6) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(7) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(8) {-height 15 -radix hexadecimal -childformat {{/top_cpu/inst_RAM/memoire(8)(7) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8)(6) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8)(5) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8)(4) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8)(3) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8)(2) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8)(1) -radix hexadecimal} {/top_cpu/inst_RAM/memoire(8)(0) -radix hexadecimal}}} /top_cpu/inst_RAM/memoire(8)(7) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(8)(6) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(8)(5) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(8)(4) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(8)(3) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(8)(2) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(8)(1) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(8)(0) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(9) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(10) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(11) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(12) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(13) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(14) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(15) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(16) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(17) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(18) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(19) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(20) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(21) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(22) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(23) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(24) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(25) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(26) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(27) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(28) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(29) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(30) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(31) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(32) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(33) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(34) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(35) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(36) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(37) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(38) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(39) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(40) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(41) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(42) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(43) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(44) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(45) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(46) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(47) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(48) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(49) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(50) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(51) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(52) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(53) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(54) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(55) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(56) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(57) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(58) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(59) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(60) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(61) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(62) {-height 15 -radix hexadecimal} /top_cpu/inst_RAM/memoire(63) {-height 15 -radix hexadecimal}} /top_cpu/inst_RAM/memoire
add wave -noupdate -group UT /top_cpu/inst_ut/reset
add wave -noupdate -group UT /top_cpu/inst_ut/clk
add wave -noupdate -group UT /top_cpu/inst_ut/clk_en
add wave -noupdate -group UT -radix hexadecimal /top_cpu/inst_ut/data_in
add wave -noupdate -group UT -radix hexadecimal /top_cpu/inst_ut/data_out
add wave -noupdate -group UT /top_cpu/inst_ut/carry
add wave -noupdate -group UT /top_cpu/inst_ut/sel_ual
add wave -noupdate -group UT /top_cpu/inst_ut/load_ra
add wave -noupdate -group UT /top_cpu/inst_ut/load_ff
add wave -noupdate -group UT /top_cpu/inst_ut/load_rd
add wave -noupdate -group UT /top_cpu/inst_ut/init_ff
add wave -noupdate -group UT -radix hexadecimal /top_cpu/inst_ut/reg_data_to_UAL
add wave -noupdate -group UT -radix hexadecimal /top_cpu/inst_ut/reg_accu_to_UAL
add wave -noupdate -group UT -radix hexadecimal /top_cpu/inst_ut/UAL_out_to_accu
add wave -noupdate -group UT /top_cpu/inst_ut/UAL_carry_to_ff
add wave -noupdate -group UT /top_cpu/inst_ut/ff_input
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1270 ps} 0} {{Cursor 2} {461 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1800 ps}
