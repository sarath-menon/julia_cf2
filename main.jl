
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

const duration::Integer = 3
const gyro_cb_len::Integer = 5

samples_channel = Channel{GyroData}(100);

include("src/tasks/tasks.jl")

sensors_task(samples_channel, duration)
estimator_task(samples_channel)

##






