include("logger_struct.jl")


const duration_::Int32 = 3

main_task = @task begin

    gui_data = reset_plot(gui)
    task_rate = 1000 #hz

    println("Waiting to receive samples from channel")

    # wait for data to become available in the channel
    wait(samples_channel)

    count = duration_ * 1000

    for i in 1:count
        sample = take!(samples_channel)

        # push data to circular buffer
        push!(gyro_cb, sample)

        if i % 10 == 0
            plot_gyro(gui_data, i, sample)
        end

        # sleep(1 / task_rate)
    end


end



cfread_task = @task begin


    log_obj = LoggerStruct1("usb://0", pyimport("cflib"), pyimport("time"), pyimport("cflib.crazyflie"), pyimport("cflib.crazyflie.syncLogger"), pyimport("logging"))

    log_profiles = LogProfiles(log_obj.crazyflie.log.LogConfig(name="Stabilizer", period_in_ms=10))
    log_init(log_obj, log_profiles)
    log_start(log_obj, log_profiles, duration_)
end