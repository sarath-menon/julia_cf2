
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

        println("Waiting to receive samples from channel")

        # wait for data to become available in the channel
        wait(samples_channel)

        duration = 5
        count = duration * 1000


        for i in 1:count
            sample = take!(samples_channel)
            # Core.println("Popped Timestamp $(i): ", sample.timestamp)

            Core.println("Gyro x $(sample.timestamp): ", sample.ẋ)
            # sleep(1 / task_rate)
        end

        close(soc)
    end

end


