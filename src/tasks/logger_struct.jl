
include("socket_udp.jl")

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

##

##
function log_init(log_obj::LoggerStruct1, log_profiles::LogProfiles)

    log_obj.logging.basicConfig(level=log_obj.logging.ERROR)


    # Initialize the low-level drivers
    log_obj.cflib.crtp.init_drivers()

    #lg_stab = log_obj.crazyflie.log.LogConfig(name="Stabilizer", period_in_ms=10)
    log_profiles.lg_stab.add_variable("gyro_unfiltered.x", "float")
    log_profiles.lg_stab.add_variable("gyro_unfiltered.y", "float")
    log_profiles.lg_stab.add_variable("gyro_unfiltered.z", "float")

end


# setter function 
function simple_log(log_obj::LoggerStruct1, log_profiles::LogProfiles, scf, count_max::Integer)

    # get ip address of host
    ip_address = getipaddr()
    soc = UDPSocket()
    io = IOBuffer()
    port = 4444

    @pywith log_obj.crazyflie.syncLogger.SyncLogger(scf, log_profiles.lg_stab) as logger begin

        count::Integer = 0
        fps::Integer = 1000



        for log_entry in logger

            timestamp = log_entry[1]
            data = log_entry[2]
            logconf_name = log_entry[3]

            # Core.println("Pushed Timestamp: ", timestamp)
            # @printf "   Raw gyro: %.3f    %.3f    %.3f" data["gyro_unfiltered.x"] data["gyro_unfiltered.y"] data["gyro_unfiltered.z"]
            # println("")


            sample = GyroData(timestamp, data["gyro_unfiltered.x"], data["gyro_unfiltered.y"], data["gyro_unfiltered.z"])

            # send data to gui
            serialize(io, sample)
            data = take!(io)
            ret = send(soc, ip_address, port, data)

            if ret == false
                println("Could not send data !")
            end


            # put!(samples_channel, sample)
            # push data to circular buffer
            # lock(lk) do
            #     push!(task_cb, sample.ẋ)
            # end
            # unlock(lk)

            begin
                lock(lk)
                try
                    push!(task_cb, sample)
                    push!(gyro_cb, sample.ẋ)
                finally
                    unlock(lk)
                end
            end

            count += 1

            if count == count_max
                break
            end


            # sleep(1 / fps)
        end
    end
    Core.println("Crazyflie done publishing !")

end



function log_start(log_obj::LoggerStruct1, log_profiles::LogProfiles, duration::Integer)

    count_max = duration * 1000

    @pywith log_obj.crazyflie.syncCrazyflie.SyncCrazyflie(log_obj.uri, cf=log_obj.crazyflie.Crazyflie(rw_cache="./cache")) as scf begin
        simple_log(log_obj::LoggerStruct1, log_profiles::LogProfiles, scf, count_max)
    end


end


