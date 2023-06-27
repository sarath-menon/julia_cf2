
include("socket_udp.jl")

function main_task(samples_channel::Channel)

    # main_task = @task begin
    @tspawnat 2 begin

        # create chebyshev filter 
        ripple = 3 # max passband ripple in dB
        f_s = 1000 # sampling time [hz]
        f_c = 80 # cutoff frequency [hz]
        m = 4 # filter order

        responsetype = Lowpass(f_c; fs=f_s)
        designmethod = Chebyshev1(m, ripple)

        chebyshev_filter = digitalfilter(responsetype, designmethod)

        task_rate = 1000 #hz

        # create circular buffer to hold gyro data

        # gyro_cb = CircularBuffer{Float64}(gyro_cb_len)
        # gyro_cb = CircularBuffer{Float64}(gyro_cb_len)
        # gyro_cb = CircularBuffer{Float64}(gyro_cb_len)


        println("Waiting to receive samples from channel")

        # wait for data to become available in the channel
        # wait(samples_channel)

        duration = 5
        count = duration * 1000


        # get ip address of host
        ip_address = getipaddr()
        soc = UDPSocket()
        io = IOBuffer()
        port = 4444

        timestamp::Int64 = 0


        for i in 1:count
            # sample = take!(samples_channel)
            # lock(lk) do
            #     sample = pop!(task_cb)
            # end



            # begin
            #     # Core.println("Waiting to lock")
            #     lock(lk)
            #     try
            #         sample = popfirst!(task_cb)
            #         # timestamp = sample.timestamp
            #         # Core.println("Popped Timestamp $(i): ", sample.timestamp)

            #         # apply flilter to data in circular buffer
            #         # gyro_filtered_x = filt(chebyshev_filter, task_cb.buffer)

            #         println("Filtered $(sample.timestamp): ", sample.ẋ)

            #         # gyro_filtered_x = filt(chebyshev_filter, gyro_cb.buffer)

            #         # # println("Filtered $(sample.timestamp): ", gyro_filtered_x[5])
            #         # println("Filtered $(timestamp): ", gyro_filtered_x[5])

            #     finally
            #         unlock(lk)
            #     end
            # end

            sample = take!(samples_channel)
            Core.println("Popped Timestamp $(i): ", sample.timestamp)


            # # pop latest data from circular buffer

            # # push data to circular buffer
            # push!(gyro_cb, sample.ẋ)



            # println("Gyro x:", sample[1])
            # println("Index", i)


            # # state = GyroData(i, sample[1], sample[2], sample[3])
            # serialize(io, sample)

            # send_data(take!(io))




            # # send data to gui channel
            # if i % 10 == 0
            #     data = take!(io)
            #     ret = send(soc, ip_address, port, data)
            #     if ret == false
            #         println("Could not send data !")
            #     end

            # end

            # sleep(1 / task_rate)
        end

        # # to shutdown gui receiver
        # data = :exit
        # serialize(io, data)
        # ret = send(soc, ip_address, port, data)
        # if ret == false
        #     println("Could not send data !")
        # end

        close(soc)
    end

end


