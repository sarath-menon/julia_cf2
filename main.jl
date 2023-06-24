
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



##

# create circular buffer to hold gyro data
const gyro_cb_len::Integer = 5
gyro_cb = CircularBuffer{Array{Float64,2}}(gyro_cb_len)

##
include("tasks.jl")


schedule(cfread_task)
schedule(main_task)



