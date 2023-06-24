
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

using Sockets
using Serialization


GLMakie.activate!(inline=false)
##

include("src/tasks/comm_utils.jl")


data_channel = Channel{GyroData}(100);


include("src/tasks/socket_task.jl")
include("src/tasks/onetime_tasks.jl")

schedule(gui_task)
# schedule(socket_task)





