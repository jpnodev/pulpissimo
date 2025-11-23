define n


endef # make errors more visually appealing

export BOARD=basys3

# Basys3 board configuration
export XILINX_PART=xc7a35tcpg236-1
export XILINX_BOARD=digilentinc.com:basys3:part0:1.2

# Clock periods for 100MHz input clock
# FC at 10MHz, PER at 5MHz
export FC_CLK_PERIOD_NS=100
export PER_CLK_PERIOD_NS=200
export SLOW_CLK_PERIOD_NS=30517

$(info Setting environment variables for $(BOARD) board)
