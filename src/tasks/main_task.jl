
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

        gyro_cb = CircularBuffer{Float64}(gyro_cb_len)
        # gyro_cb = CircularBuffer{Float64}(gyro_cb_len)
        # gyro_cb = CircularBuffer{Float64}(gyro_cb_len)


        println("Waiting to receive samples from channel")

        # wait for data to become available in the channel
        # wait(samples_channel)

        count = duration * 1000

        for i in 1:count
            sample = take!(samples_channel)

            # push data to circular buffer
            push!(gyro_cb, sample[1])

            # apply flilter to data in circular buffer
            gyro_filtered_x = filt(chebyshev_filter, gyro_cb.buffer)

            println("Gyro x:", sample[1])


            # # push data to gui channel
            # if i % 10 == 0
            #     put!(gui_channel, sample)

            # end

            # sleep(1 / task_rate)
        end
    end

end


