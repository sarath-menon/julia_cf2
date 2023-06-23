main_task = @task begin

    reset_plot(gui)
    task_rate = 1000 #hz

    println("Waiting to receive samples from channel")

    # wait for data to become available in the channel
    wait(samples_channel)

    for i in 1:1000
        sample = take!(samples_channel)

        # push data to circular buffer
        push!(gyro_cb, sample)

        if i % 10 == 0
            plot_gyro(gui, i, sample)
        end

        sleep(1 / task_rate)
    end


end



cfread_task = @task begin

    log_profiles = LogProfiles(log_obj.crazyflie.log.LogConfig(name="Stabilizer", period_in_ms=10))
    log_init(log_obj, log_profiles)
    log_start(log_obj, log_profiles, duration)
end