import Pkg;
Pkg.activate(@__DIR__);
Pkg.instantiate();

using Revise
import julia_cf2

using PyCall
using Printf

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


# callback function
function log_stab_callback(timestamp, data, logconf)
    print("Timestamp: ", timestamp)
    @printf "   Raw gyro: %.3f    %.3f    %.3f" data["gyro_unfiltered.x"] data["gyro_unfiltered.x"] data["gyro_unfiltered.x"]
    println("")
end


function simple_log_async(scf, logconf)
    cf = scf.cf
    cf.log.add_config(logconf)
    logconf.data_received_cb.add_callback(log_stab_callback)
    logconf.start()
    time.sleep(5)
    logconf.stop()
end

#     @pywith crazyflie.syncLogger.SyncLogger(scf, lg_stab) as logger begin

#         count = 0

#         for log_entry in logger
#             timestamp = log_entry[1]
#             data = log_entry[2]
#             logconf_name = log_entry[3]

#             # print('[%d][%s]: %s' % (timestamp, logconf_name, data))
#             print("Timestamp: ", timestamp)
#             @printf "   Raw gyro: %.3f    %.3f    %.3f" data["gyro_unfiltered.x"] data["gyro_unfiltered.x"] data["gyro_unfiltered.x"]
#             println("")

#             # println("   Pitch: ", data["stabilizer.pitch"])

#             count = count + 1

#             if count == 100
#                 break
#             end
#         end
#     end
# end

# Initialize the low-level drivers
cflib.crtp.init_drivers()
lg_stab = log.LogConfig(name="Stabilizer", period_in_ms=10)

lg_stab.add_variable("gyro_unfiltered.x", "float")
lg_stab.add_variable("gyro_unfiltered.y", "float")
lg_stab.add_variable("gyro_unfiltered.z", "float")


@pywith crazyflie.syncCrazyflie.SyncCrazyflie(uri, cf=crazyflie.Crazyflie(rw_cache="./cache")) as scf begin
    # print("Hello World!")
    simple_log_async(scf, lg_stab)
end