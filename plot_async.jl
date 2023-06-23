import Pkg;
Pkg.activate(@__DIR__);
Pkg.instantiate();

import julia_cf2
using PyCall
using Printf
using DataStructures
using GLMakie

include("logger_class.jl")

GLMakie.activate!(inline=false)

##

# create GLMakie plot
f = Figure()
ax = Axis(f[1, 1])

deregister_interaction!(ax, :rectanglezoom)
limits!(ax, 0, 10, -4, 4)

display(f)

##

# create circular buffer to hold gyro data
buffer_len = 5
gyro_cb = CircularBuffer{Array{Float64,2}}(buffer_len)


# for glmakie rad_per_sample_to_hz
points = Observable(Point2f[])
# add line plot
lines!(ax, points)

# URI to the Crazyflie to connect to
uri = "usb://0"

app = Cf2Logger(uri)

duration = 2
app.log_start(gyro_cb, points, duration)

println(cb)

##
empty!(ax)