vlib work
 
vlog -timescale 1ns/1ns part2.v
 
vsim part2
 
# Log all signals and add some signals to waveform window.
log {/*}
# add wave {/*} would add all items in top level simulation module.
add wave {/*}
 
force {CLOCK_50} 0 0, 1 1ns -r 2ns

force {KEY} 0000
run 2ns

force {KEY} 0001
force {SW} 1100000000 
run 500ns 
