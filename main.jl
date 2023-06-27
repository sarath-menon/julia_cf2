
import Pkg;
Pkg.activate(@__DIR__);

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

lk = ReentrantLock()
samples_channel = Channel{GyroData}(100);

task_cb = CircularBuffer{GyroData}(5)

include("src/tasks/tasks.jl")



cfread_task_func(samples_channel, 5)
main_task(samples_channel)

##






