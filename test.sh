# iverilog src/*.v tb/*.v
# iverilog -o simv src/fpcvt.v tb/fpcvt_tb.v
# vvp simv

iverilog -g2012 -DSIM -o sim.out src/*.v tb/top_tb.v
vvp sim.out