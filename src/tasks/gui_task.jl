# module gui_task_

using GLMakie
GLMakie.activate!(inline=false)

# include("./../tasks/comm_utils.jl")
include("./../lib/gui.jl")

function gui_task_func(data_channel::Channel)

    gui_task = @async begin

        ## initialize the gui
        gui = gui_init()
        gui_data = reset_plot(gui)
        fps::Integer = 1000

        display(gui.fig)

        # # wait for data to become available in the channel
        # wait(data_channel)

        duration = 5
        count = duration * 1000
        println("Waiting for data in gui:")



        for i in 1:1:count


            sample::GyroData = take!(data_channel)

            print("Index :", i)

            # println("Data received :", sample.ẋ)

            # println("plotting data")
            plot_gyro(gui_data, i, sample)

            sleep(1 / fps)
        end


    end

    return gui_task

end
# end

