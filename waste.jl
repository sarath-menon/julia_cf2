
import Pkg;
Pkg.activate(@__DIR__);
Pkg.instantiate();

using Revise
import julia_cf2
using PyCall
using Printf
using DataStructures
using GLMakie

GLMakie.activate!(inline=false)
##
include("gui.jl")

gui = gui_init()

display(gui.fig)

##

# create circular buffer to hold gyro data
buffer_len = 5
gyro_cb = CircularBuffer{Array{Float64,2}}(buffer_len)

include("logger_struct.jl")

log_obj = LoggerStruct1("usb://0", pyimport("cflib"), pyimport("time"), pyimport("cflib.crazyflie"), pyimport("cflib.crazyflie.syncLogger"), pyimport("logging"))

duration = 2

##
include("tasks.jl")


schedule(cfread_task);
schedule(main_task);

##

# clear axes
empty!(gui.ax1)
empty!(gui.ax2)
empty!(gui.ax3)


