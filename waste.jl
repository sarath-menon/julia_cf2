
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

display(gui.fig)

##

# create circular buffer to hold gyro data
buffer_len = 5
gyro_cb = CircularBuffer{Array{Float64,2}}(buffer_len)

include("logger_struct.jl")

log_obj = LoggerStruct1("usb://0", pyimport("cflib"), pyimport("time"), pyimport("cflib.crazyflie"), pyimport("cflib.crazyflie.syncLogger"), pyimport("logging"))

duration = 2

##

main_task = @task begin

    reset_plot(gui)

    println("Waiting to receive samples from channel")

    for i in 1:1000
        sample = take!(samples_channel)

        # push data to circular buffer
        push!(gyro_cb, sample)

        if i % 10 == 0
            plot_gyro(gui, i, sample)
        end
    end
end

##

cfread_task = @task begin

    log_profiles = LogProfiles(log_obj.crazyflie.log.LogConfig(name="Stabilizer", period_in_ms=10))
    log_init(log_obj, log_profiles)
    log_start(log_obj, log_profiles, duration)
end

##

schedule(cfread_task);
schedule(main_task);

##

empty!(ax1)
empty!(ax2)
empty!(ax3)


