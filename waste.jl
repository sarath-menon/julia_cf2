
import Pkg;
Pkg.activate(@__DIR__);
Pkg.instantiate();

import julia_cf2
using PyCall
using Printf
using DataStructures
using GLMakie

GLMakie.activate!(inline=false)
##


# create GLMakie plot
fig = Figure()
ax = Axis(fig[1, 1])

deregister_interaction!(ax, :rectanglezoom)
x_range = 10
limits!(ax, 0, x_range, -4, 4)

display(fig)



##

# create circular buffer to hold gyro data
buffer_len = 5
gyro_cb = CircularBuffer{Array{Float64,2}}(buffer_len)


# for glmakie rad_per_sample_to_hz
points = Observable(Point2f[])
x = Observable(Real)

# add line plot
lines!(ax, points)


# # for dynamically updating the axes
# on(points) do point
#     # x_right_limit = last(points.val)[1][1]
#     x_right_limit = 50

#     if x_right_limit >= x_range
#         x_left_limit = x_right_limit - x_range
#     else
#         x_left_limit = 0
#     end

#     limits!(ax, x_left_limit, x_right_limit, -4, 4)
# end


include("logger_struct.jl")

log_obj = LoggerStruct1("usb://0", pyimport("cflib"), pyimport("time"), pyimport("cflib.crazyflie"), pyimport("cflib.crazyflie.syncLogger"), pyimport("logging"))



duration = 2

##
@async begin
    for i in 1:1000
        sample = take!(samples_channel)
        push!(gyro_cb, [sample sample sample])

        println(i, sample)
    end
end

##
log_profiles = LogProfiles(log_obj.crazyflie.log.LogConfig(name="Stabilizer", period_in_ms=10))
log_init(log_obj, log_profiles)
log_start(log_obj, log_profiles, gyro_cb, points, duration)


##

# empty!(ax)


