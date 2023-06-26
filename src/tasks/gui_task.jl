

include("gui.jl")

# using .gui
import .gui


function plot_gyro1(gui_data, i, msg)
    # push data to plot buffer
    gui_data.points_x[] = push!(gui_data.points_x[], [(i / 1000) msg.ẋ])
    gui_data.points_y[] = push!(gui_data.points_y[], [(i / 1000) msg.ẏ])
    gui_data.points_z[] = push!(gui_data.points_z[], [(i / 1000) msg.ż])
end


gui_task = @task begin

    ## initialize the gui
    gui_task_handle::gui.Gui = gui.gui_init()
    gui_data::gui.GuiData = gui.reset_plot(gui_task_handle)
    fps::Integer = 1000

    display(gui_task_handle.fig)

    # # wait for data to become available in the channel
    # wait(data_channel)

    duration = 5
    count = duration * 1000000



    for i in 1:count
        println("Waiting for data in gui:")

        sample::GyroData = take!(data_channel)

        println("Data received $(i) :", sample)

        println("plotting data")
        # plot_gyro1(gui_data, i, sample)
        # gui.plot_gyro(gui_data, i, sample)

        gui_data.points_x[] = push!(gui_data.points_x[], [(i) sample.ẋ])
        gui_data.points_y[] = push!(gui_data.points_y[], [(i) sample.ẏ])
        gui_data.points_z[] = push!(gui_data.points_z[], [(i) sample.ż])

        # sleep(1 / fps)
    end


end



