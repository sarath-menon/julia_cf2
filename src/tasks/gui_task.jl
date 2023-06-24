

include("./../lib/gui.jl")



gui_task = @task begin

    ## initialize the gui
    gui = gui_init()
    gui_data = reset_plot(gui)
    fps::Integer = 1000

    display(gui.fig)

    # wait for data to become available in the channel
    wait(gui_channel)

    count = duration * 10000

    for i in 1:count
        sample = take!(gui_channel)

        # println("plotting data")

        plot_gyro(gui_data, i, sample)

        sleep(1 / fps)
    end


end



