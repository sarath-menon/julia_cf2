

include("./../lib/gui.jl")



gui_task = @task begin

    ## initialize the gui
    gui = gui_init()
    gui_data = reset_plot(gui)

    # wait for data to become available in the channel
    wait(gui_channel)

    count = duration * 1000

    for i in 1:count
        sample = take!(gui_channel)

        # if i % 10 == 0
        plot_gyro(gui_data, i, sample)
        # end

        # sleep(1 / task_rate)
    end


end



