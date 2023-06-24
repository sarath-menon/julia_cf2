
import Pkg;
Pkg.activate(@__DIR__);
Pkg.instantiate();

##
using Revise
import julia_cf2
using Printf
using DataStructures
using GLMakie
using ThreadPools
using DSP

GLMakie.activate!(inline=false)
##

include("src/tasks/onetime_tasks.jl")
include("src/tasks/socket_task.jl")

schedule(gui_task)
schedule(socket_task)





