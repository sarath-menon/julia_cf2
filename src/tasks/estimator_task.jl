
include("socket_udp.jl")

function estimator_task(samples_channel::Channel)

    # main_task = @task begin
    @tspawnat 2 begin

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


