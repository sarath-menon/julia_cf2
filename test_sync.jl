import Pkg;
Pkg.activate(@__DIR__);
Pkg.instantiate();

import julia_cf2
using PyCall
using Printf

# package imports
cflib = pyimport("cflib")
logging = pyimport("logging")
time = pyimport("time")

crazyflie = pyimport("cflib.crazyflie")
log = pyimport("cflib.crazyflie.log")
syncLogger = pyimport("cflib.crazyflie.syncLogger")

# URI to the Crazyflie to connect to
uri = "usb://0"

# Only output errors from the logging framework
logging.basicConfig(level=logging.ERROR)

cb = CircularBuffer{Array{Float64,2}}(buffer_len)

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

            count = count + 1

            if count == 100
                break
            end
        end
    end

    println(cb)

end

# Initialize the low-level drivers
cflib.crtp.init_drivers()

lg_stab = log.LogConfig(name="Stabilizer", period_in_ms=10)
lg_stab.add_variable("gyro_unfiltered.x", "float")
lg_stab.add_variable("gyro_unfiltered.y", "float")
lg_stab.add_variable("gyro_unfiltered.z", "float")

time.sleep(1)

@async begin
    @pywith crazyflie.syncCrazyflie.SyncCrazyflie(uri, cf=crazyflie.Crazyflie(rw_cache="./cache")) as scf begin
        # print("Hello World!")
        simple_log(scf, lg_stab)
    end
end



