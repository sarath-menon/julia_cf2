
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

    # create chebyshev filter 
    ripple = 3 # max passband ripple in dB
    f_s = 1000 # sampling time [hz]
    f_c = 80 # cutoff frequency [hz]
    m = 4 # filter order

    responsetype = Lowpass(f_c; fs=f_s)
    designmethod = Chebyshev1(m, ripple)
    chebyshev_filter = digitalfilter(responsetype, designmethod)

    # create circular buffer to hold gyro data
    gyro_cb_x = CircularBuffer{Float64}(gyro_cb_len)
    gyro_cb_y = CircularBuffer{Float64}(gyro_cb_len)
    gyro_cb_z = CircularBuffer{Float64}(gyro_cb_len)

    gyro_filtered_x = Array{Float64}(undef, gyro_cb_len)
    gyro_filtered_x = Array{Float64}(undef, gyro_cb_len)
    gyro_filtered_x = Array{Float64}(undef, gyro_cb_len)


    @pywith log_obj.crazyflie.syncLogger.SyncLogger(scf, log_profiles.lg_stab) as logger begin

        count::Integer = 0
        # fps::Integer = 1000

        for log_entry in logger

            timestamp = log_entry[1]
            data = log_entry[2]
            logconf_name = log_entry[3]

            # @printf "   Raw gyro: %.3f    %.3f    %.3f" data["gyro_unfiltered.x"] data["gyro_unfiltered.y"] data["gyro_unfiltered.z"]
            # println("")

            push!(gyro_cb_x, data["gyro_unfiltered.x"])
            push!(gyro_cb_y, data["gyro_unfiltered.x"])
            push!(gyro_cb_x, data["gyro_unfiltered.x"])


            if count % 2 == 0
                # Core.println("Pushed Timestamp: ", timestamp)

                gyro_filtered_x = filt(chebyshev_filter, gyro_cb_x.buffer)
                gyro_filtered_y = filt(chebyshev_filter, gyro_cb_y.buffer)
                gyro_filtered_z = filt(chebyshev_filter, gyro_cb_z.buffer)

                sample = GyroData(timestamp, gyro_filtered_x[5], gyro_filtered_y[5], gyro_filtered_z[5])

                push!(samples_channel, sample)

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


