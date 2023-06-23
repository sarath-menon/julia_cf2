
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
ax1 = Axis(fig[1, 1])
ax2 = Axis(fig[2, 1])
ax3 = Axis(fig[3, 1])

x_range = 10
limits!(ax1, 0, x_range, -4, 4)
limits!(ax2, 0, x_range, -4, 4)
limits!(ax3, 0, x_range, -4, 4)

deregister_interaction!(ax1, :rectanglezoom)
deregister_interaction!(ax2, :rectanglezoom)
deregister_interaction!(ax3, :rectanglezoom)

display(fig)



##

# create circular buffer to hold gyro data
buffer_len = 5
gyro_cb = CircularBuffer{Array{Float64,2}}(buffer_len)

include("logger_struct.jl")

log_obj = LoggerStruct1("usb://0", pyimport("cflib"), pyimport("time"), pyimport("cflib.crazyflie"), pyimport("cflib.crazyflie.syncLogger"), pyimport("logging"))

duration = 2

##
@async begin
    # add line plot
    points_x = Observable(Point2f[])
    points_y = Observable(Point2f[])
    points_z = Observable(Point2f[])

    lines!(ax1, points_x)
    lines!(ax2, points_y)
    lines!(ax3, points_z)

    # # for dynamically updating the axes
    # on(points) do point
    #     x_right_limit = last(points.val)[1][1]
    #     # x_right_limit = 50

    #     if x_right_limit >= x_range
    #         x_left_limit = x_right_limit - x_range
    #     else
    #         x_left_limit = 0
    #     end

    #     limits!(ax, x_left_limit, x_right_limit, -4, 4)
    # end

    for i in 1:1000
        sample = take!(samples_channel)

        # push data to circular buffer
        push!(gyro_cb, sample)

        if i % 10 == 0
            # push data to plot buffer
            points_x[] = push!(points_x[], [(i / 1000) sample[1]])
            points_y[] = push!(points_y[], [(i / 1000) sample[2]])
            points_z[] = push!(points_z[], [(i / 1000) sample[3]])
        end

        # println(i, sample)
    end
end

##


log_profiles = LogProfiles(log_obj.crazyflie.log.LogConfig(name="Stabilizer", period_in_ms=10))
log_init(log_obj, log_profiles)
log_start(log_obj, log_profiles, duration)


##

empty!(ax1)
empty!(ax2)
empty!(ax3)


