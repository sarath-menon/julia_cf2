
include("socket_udp.jl")

function estimator_task(samples_channel::Channel)

    # main_task = @task begin
    @tspawnat 2 begin

        println("Waiting to receive samples from channel")

        # wait for data to become available in the channel
        wait(samples_channel)

        duration = 5
        count = duration * 1000


        while true
            sample = take!(samples_channel)
            # Core.println("Popped Timestamp $(i): ", sample.timestamp)

            Core.println("Accel $(sample.timestamp): $(sample.acc.x) $(sample.acc.y) $(sample.acc.z) ")
            Core.println("Gyro $(sample.timestamp): $(sample.gyro.ẋ) $(sample.gyro.ẏ) $(sample.gyro.ż) ")

            # @printf "Raw accel %d: %.3f    %.3f    %.3f \n" sample.timestamp sample.acc.x sample.acc.y sample.acc.z
            # @printf "Raw gyro %d: %.3f    %.3f    %.3f \n" sample.timestamp sample.gyro.ẋ sample.gyro.ẏ sample.gyro.ż

            # sleep(1 / task_rate)
        end

        close(soc)
    end

end


