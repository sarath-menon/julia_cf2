
import Pkg;
Pkg.activate(@__DIR__);
Pkg.instantiate();

##
using Revise
import julia_cf2
using PyCall
using Printf
using DataStructures
using ThreadPools
using DSP
using Sockets
using Serialization


GLMakie.activate!(inline=false)
##

include("src/tasks/comm_utils.jl")

include("src/tasks/tasks.jl")


main_task(samples_channel)

cfread_task_func(samples_channel)





