
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

# screen = Gtk4Makie.GTKScreen(resolution=(800, 800))
# display(screen, gui.fig)

display(gui.fig)

##

# create circular buffer to hold gyro data
const gyro_cb_len::Int32 = 5
gyro_cb = CircularBuffer{Array{Float64,2}}(buffer_len)

##
include("tasks.jl")


schedule(cfread_task)
schedule(main_task)



