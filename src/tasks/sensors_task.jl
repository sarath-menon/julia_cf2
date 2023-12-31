include("logger_struct.jl")

function sensors_task(samples_channel::Channel, duration::Int64)

    cfread_task = @async begin


        log_obj = LoggerStruct1("usb://0", pyimport("cflib"), pyimport("time"), pyimport("cflib.crazyflie"), pyimport("cflib.crazyflie.syncLogger"), pyimport("logging"))

        log_profiles = LogProfiles(log_obj.crazyflie.log.LogConfig(name="Stabilizer", period_in_ms=10))
        log_init(log_obj, log_profiles)
        log_start(log_obj, log_profiles, duration)
    end

end