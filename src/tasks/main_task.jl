

include("./../lib/gui.jl")



main_task = @task begin

    ## initialize the gui
    gui = gui_init()
    gui_data = reset_plot(gui)


    task_rate = 1000 #hz

    # create circular buffer to hold gyro data

    gyro_cb = CircularBuffer{Array{Float64,2}}(gyro_cb_len)


    println("Waiting to receive samples from channel")

    # wait for data to become available in the channel
    wait(samples_channel)

    count = duration * 1000

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



