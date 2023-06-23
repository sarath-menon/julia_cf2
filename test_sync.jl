import Pkg;
Pkg.activate(@__DIR__);
Pkg.instantiate();

import julia_cf2
using PyCall
using Printf
using DataStructures
using GLMakie

GLMakie.activate!(inline=false)
# package imports
cflib = pyimport("cflib")
logging = pyimport("logging")
time = pyimport("time")

crazyflie = pyimport("cflib.crazyflie")
log = pyimport("cflib.crazyflie.log")
syncLogger = pyimport("cflib.crazyflie.syncLogger")

# Only output errors from the logging framework
logging.basicConfig(level=logging.ERROR)

# create circular buffer
buffer_len = 5
cb = CircularBuffer{Array{Float64,2}}(buffer_len)

##

# for glmakie rad_per_sample_to_hz
points = Observable(Point2f[])

# create GLMakie plot
f = Figure()
ax = Axis(f[1, 1])
lines!(ax, points)
limits!(ax, 0, 10, -4, 4)

display(f)


##

function simple_log(scf, logconf)

    @pywith crazyflie.syncLogger.SyncLogger(scf, lg_stab) as logger begin

        count = 0
        println("selva")

        for log_entry in logger

            timestamp = log_entry[1]
            data = log_entry[2]
            logconf_name = log_entry[3]

            # print('[%d][%s]: %s' % (timestamp, logconf_name, data))
            print("Timestamp: ", timestamp)

            @printf "   Raw gyro: %.3f    %.3f    %.3f" data["gyro_unfiltered.x"] data["gyro_unfiltered.y"] data["gyro_unfiltered.z"]

            println("")

            # push data to circular buffer
            sample = [data["gyro_unfiltered.x"] data["gyro_unfiltered.y"] data["gyro_unfiltered.z"]]
            push!(cb, sample)

            # push data to plot buffer
            if count % 10 == 0
                points[] = push!(points[], [(count / 1000) data["gyro_unfiltered.x"]])
            end

            count += 1

            if count == 10000
                break
            end
        end
    end

    println(cb)

end

##

# URI to the Crazyflie to connect to
uri = "usb://0"

# Initialize the low-level drivers
cflib.crtp.init_drivers()

lg_stab = log.LogConfig(name="Stabilizer", period_in_ms=10)
lg_stab.add_variable("gyro_unfiltered.x", "float")
lg_stab.add_variable("gyro_unfiltered.y", "float")
lg_stab.add_variable("gyro_unfiltered.z", "float")


@async begin
    @pywith crazyflie.syncCrazyflie.SyncCrazyflie(uri, cf=crazyflie.Crazyflie(rw_cache="./cache")) as scf begin
        # print("Hello World!")
        simple_log(scf, lg_stab)
    end
end



