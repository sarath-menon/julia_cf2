
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

    log_profiles.lg_stab.add_variable("gyro_unfiltered.x", "float")
    log_profiles.lg_stab.add_variable("gyro_unfiltered.y", "float")
    log_profiles.lg_stab.add_variable("gyro_unfiltered.z", "float")

    log_profiles.lg_stab.add_variable("acc_unfiltered.x", "float")
    log_profiles.lg_stab.add_variable("acc_unfiltered.y", "float")
    log_profiles.lg_stab.add_variable("acc_unfiltered.z", "float")

end


# setter function 
function simple_log(log_obj::LoggerStruct1, log_profiles::LogProfiles, scf, count_max::Integer)


    # get ip address of host
    ip_address = getipaddr()
    soc = UDPSocket()
    io = IOBuffer()
    port = 4444

    # create accelerometer lowspass filter (chebyshev)
    ripple = 3 # max passband ripple in dB
    f_s = 1000 # sampling time [hz]
    f_c = 30 # cutoff frequency [hz]
    m = 4 # filter order

    responsetype = Lowpass(f_c; fs=f_s)
    designmethod = Chebyshev1(m, ripple)
    acc_lpfilter = digitalfilter(responsetype, designmethod)


    # create gyri lowspass filter (chebyshev)

    ripple = 3 # max passband ripple in dB
    f_s = 1000 # sampling time [hz]
    f_c = 80 # cutoff frequency [hz]
    m = 4 # filter order

    responsetype = Lowpass(f_c; fs=f_s)
    designmethod = Chebyshev1(m, ripple)
    gyro_lpfilter = digitalfilter(responsetype, designmethod)



    # create circular buffer to hold ccel, gyro data
    acc_cb_x = CircularBuffer{Float64}(acc_cb_len)
    acc_cb_y = CircularBuffer{Float64}(acc_cb_len)
    acc_cb_z = CircularBuffer{Float64}(acc_cb_len)

    gyro_cb_x = CircularBuffer{Float64}(gyro_cb_len)
    gyro_cb_y = CircularBuffer{Float64}(gyro_cb_len)
    gyro_cb_z = CircularBuffer{Float64}(gyro_cb_len)

    # array to hold filtered output
    acc_filtered_x = Array{Float64}(undef, acc_cb_len)
    acc_filtered_y = Array{Float64}(undef, acc_cb_len)
    acc_filtered_z = Array{Float64}(undef, acc_cb_len)

    gyro_filtered_x = Array{Float64}(undef, gyro_cb_len)
    gyro_filtered_y = Array{Float64}(undef, gyro_cb_len)
    gyro_filtered_z = Array{Float64}(undef, gyro_cb_len)


    @pywith log_obj.crazyflie.syncLogger.SyncLogger(scf, log_profiles.lg_stab) as logger begin

        count::Integer = 0
        # fps::Integer = 1000

        for log_entry in logger

            timestamp = log_entry[1]
            data = log_entry[2]
            logconf_name = log_entry[3]

            # @printf "   Raw gyro: %.3f    %.3f    %.3f" data["gyro_unfiltered.x"] data["gyro_unfiltered.y"] data["gyro_unfiltered.z"]
            # println("")

            push!(acc_cb_x, data["acc_unfiltered.x"])
            push!(acc_cb_y, data["acc_unfiltered.y"])
            push!(acc_cb_z, data["acc_unfiltered.z"])

            push!(gyro_cb_x, data["gyro_unfiltered.x"])
            push!(gyro_cb_y, data["gyro_unfiltered.y"])
            push!(gyro_cb_z, data["gyro_unfiltered.z"])


            if count % 2 == 0
                # Core.println("Pushed Timestamp: ", timestamp)

                acc_filtered_x = filt(acc_lpfilter, acc_cb_x.buffer)
                acc_filtered_y = filt(acc_lpfilter, acc_cb_y.buffer)
                acc_filtered_z = filt(acc_lpfilter, acc_cb_z.buffer)

                gyro_filtered_x = filt(gyro_lpfilter, gyro_cb_x.buffer)
                gyro_filtered_y = filt(gyro_lpfilter, gyro_cb_y.buffer)
                gyro_filtered_z = filt(gyro_lpfilter, gyro_cb_z.buffer)

                acc_data = AccData(data["acc_unfiltered.x"], data["acc_unfiltered.y"], data["acc_unfiltered.z"])
                gyro_data = GyroData(gyro_filtered_x[5], gyro_filtered_y[5], gyro_filtered_z[5])

                imu_data = ImuData(timestamp, acc_data, gyro_data)

                push!(samples_channel, imu_data)

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


