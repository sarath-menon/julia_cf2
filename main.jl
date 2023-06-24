
import Pkg;
Pkg.activate(@__DIR__);
Pkg.instantiate();
##
using Revise
import julia_cf2
using PyCall
using Printf
using DataStructures
using GLMakie
using ThreadPools
using DSP

GLMakie.activate!(inline=false)
##

include("src/tasks/onetime_tasks.jl")
schedule(gui_task)

##
include("src/tasks/tasks.jl")

schedule(cfread_task)
schedule(main_task)



