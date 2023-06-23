using Base.Threads

struct LoggerStruct1
    uri::String
    # package imports
    cflib::PyObject
    time::PyObject
    crazyflie::PyObject
    syncLogger::PyObject
    logging::PyObject
end

struct LogProfiles
    lg_stab::PyObject
end

samples_channel = Channel(1000);
# buffer_channel = Channel{CircularBuffer{Matrix{Float64}}}(1)

##

log_obj = LoggerStruct1("usb://0", pyimport("cflib"), pyimport("time"), pyimport("cflib.crazyflie"), pyimport("cflib.crazyflie.syncLogger"), pyimport("logging"))
log_profiles = LogProfiles(log_obj.crazyflie.log.LogConfig(name="Stabilizer", period_in_ms=10))

##
function log_init(log_obj::LoggerStruct1, log_profiles::LogProfiles)

    # self.uri = uri
    # # package imports
    # self.cflib = pyimport("cflib")
    # self.time = pyimport("time")

    # self.crazyflie = pyimport("cflib.crazyflie")
    # self.log = pyimport("cflib.crazyflie.log")
    # self.syncLogger = pyimport("cflib.crazyflie.syncLogger")

    # Only output errors from the logging framework
    # logging = pyimport("logging")
    log_obj.logging.basicConfig(level=log_obj.logging.ERROR)


    # Initialize the low-level drivers
    log_obj.cflib.crtp.init_drivers()

    #lg_stab = log_obj.crazyflie.log.LogConfig(name="Stabilizer", period_in_ms=10)
    log_profiles.lg_stab.add_variable("gyro_unfiltered.x", "float")
    log_profiles.lg_stab.add_variable("gyro_unfiltered.y", "float")
    log_profiles.lg_stab.add_variable("gyro_unfiltered.z", "float")
    # # test
    # self.x = 4
end

##



# setter function 
function simple_log(log_obj::LoggerStruct1, log_profiles::LogProfiles, scf)


    @pywith log_obj.crazyflie.syncLogger.SyncLogger(scf, log_profiles.lg_stab) as logger begin

        count = 0
        count_max = 1000

        for log_entry in logger

            timestamp = log_entry[1]
            data = log_entry[2]
            logconf_name = log_entry[3]

            # print("Timestamp: ", timestamp)
            # @printf "   Raw gyro: %.3f    %.3f    %.3f" data["gyro_unfiltered.x"] data["gyro_unfiltered.y"] data["gyro_unfiltered.z"]
            # println("")

            # push data to channel
            sample = [data["gyro_unfiltered.x"] data["gyro_unfiltered.y"] data["gyro_unfiltered.z"]]

            # println("Waiting for channel to be read)
            put!(samples_channel, sample)

            count += 1

            if count == count_max
                break
            end

            fps = 1000
            # sleep(1 / fps)
        end
    end
end



function log_start(log_obj::LoggerStruct1, log_profiles::LogProfiles, duration=5)

    count_max = duration * 1000

    @pywith log_obj.crazyflie.syncCrazyflie.SyncCrazyflie(log_obj.uri, cf=log_obj.crazyflie.Crazyflie(rw_cache="./cache")) as scf begin
        simple_log(log_obj::LoggerStruct1, log_profiles::LogProfiles, scf)
    end


end


