onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lab7top_tb1/sim_KEY
add wave -noupdate /lab7top_tb1/DUT/mem_cmd
add wave -noupdate -radix decimal -radixshowbase 0 /lab7top_tb1/DUT/mem_addr
add wave -noupdate /lab7top_tb1/DUT/msel
add wave -noupdate /lab7top_tb1/DUT/enable
add wave -noupdate -radix decimal -radixshowbase 0 /lab7top_tb1/DUT/read_data
add wave -noupdate -radix decimal -radixshowbase 0 /lab7top_tb1/DUT/read_address
add wave -noupdate /lab7top_tb1/DUT/dout
add wave -noupdate /lab7top_tb1/DUT/write_data
add wave -noupdate -radix decimal -radixshowbase 0 /lab7top_tb1/DUT/write_address
add wave -noupdate /lab7top_tb1/DUT/out
add wave -noupdate /lab7top_tb1/DUT/write
add wave -noupdate -radix decimal -radixshowbase 0 /lab7top_tb1/DUT/din
add wave -noupdate -radix unsigned -radixshowbase 0 /lab7top_tb1/DUT/present_state
add wave -noupdate -radix decimal -radixshowbase 0 /lab7top_tb1/DUT/pc_out
add wave -noupdate -radix decimal -radixshowbase 0 /lab7top_tb1/DUT/R0
add wave -noupdate -radix decimal -radixshowbase 0 /lab7top_tb1/DUT/R1
add wave -noupdate -radix decimal -radixshowbase 0 /lab7top_tb1/DUT/R2
add wave -noupdate -radixshowbase 0 /lab7top_tb1/DUT/R3
add wave -noupdate -radix decimal -radixshowbase 0 /lab7top_tb1/DUT/R4
add wave -noupdate -radixshowbase 0 /lab7top_tb1/DUT/R5
add wave -noupdate -radixshowbase 0 /lab7top_tb1/DUT/R6
add wave -noupdate -radix decimal -radixshowbase 0 /lab7top_tb1/DUT/R7
add wave -noupdate /lab7top_tb1/DUT/load_addr
add wave -noupdate /lab7top_tb1/DUT/addr_sel
add wave -noupdate /lab7top_tb1/err
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {538 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 137
configure wave -valuecolwidth 40
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
WaveRestoreZoom {495 ps} {595 ps}
