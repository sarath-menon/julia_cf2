

include("./../lib/gui.jl")

gui_task = @task begin

    ## initialize the gui
    gui_handle = gui.gui_init()
    gui_data = gui.reset_plot(gui_handle)
    fps::Integer = 1000

    display(gui_handle.fig)

    # wait for data to become available in the channel
    wait(gui_channel)

    count = duration * 1000

    for i in 1:count
        sample = take!(gui_channel)

        # println("plotting data")

        plot_gyro(gui_data, i, sample)

        sleep(1 / fps)
    end


end



