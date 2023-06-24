struct Gui3
    fig::Figure
    ax1::Axis
    ax2::Axis
    ax3::Axis
    x_range::Integer
end

struct GuiData
    points_x::Observable{Vector{Point{2,Float32}}}
    points_y::Observable{Vector{Point{2,Float32}}}
    points_z::Observable{Vector{Point{2,Float32}}}
end

Gui = Gui3
GuiData1 = GuiData

function gui_init()
    fig = Figure()

    # common properties
    titlesize = 30
    ylabelsize = 20

    xticklabelsize = 20
    yticklabelsize = 20

    ax1 = Axis(fig[1, 1], title="Gyro X", titlesize=titlesize, ylabelsize=ylabelsize, yticklabelsize=yticklabelsize, xticklabelsize=xticklabelsize)
    ax2 = Axis(fig[2, 1], title="Gyro Y", titlesize=titlesize, ylabelsize=ylabelsize, yticklabelsize=yticklabelsize, xticklabelsize=xticklabelsize)
    ax3 = Axis(fig[3, 1], title="Gyro Z", titlesize=titlesize, ylabelsize=ylabelsize, yticklabelsize=yticklabelsize, xticklabelsize=xticklabelsize)

    # set axis range
    x_range = 10
    limits!(ax1, 0, x_range, -4, 4)
    limits!(ax2, 0, x_range, -4, 4)
    limits!(ax3, 0, x_range, -4, 4)

    # disable interaction for all axes
    deregister_interaction!(ax1, :rectanglezoom)
    deregister_interaction!(ax2, :rectanglezoom)
    deregister_interaction!(ax3, :rectanglezoom)

    # add line plot
    points_x = Observable(Point2f[])
    points_y = Observable(Point2f[])
    points_z = Observable(Point2f[])

    gui = Gui(fig, ax1, ax2, ax3, x_range)

    # # add buttons
    add_buttons!(gui)

    display(fig)

    return gui
end

function add_buttons!(gui::Gui)

    fig = gui.fig

    # add buttons
    fig[4, 1] = buttongrid = GridLayout(tellwidth=false)

    read_button = Button(fig, label="Stop Reading", fontsize=30, tellwidth=false, halign=:center)
    log_button = Button(fig, label="Stop logging", fontsize=30, tellwidth=false, halign=:center)
    clear_button = Button(fig, label="Clear plot", fontsize=30, tellwidth=false, halign=:center)

    buttongrid[1, 1] = read_button
    buttongrid[1, 2] = log_button
    buttongrid[1, 3] = clear_button

    fig[4, 1] = buttongrid = GridLayout()

    on(read_button.clicks) do n
        println("Read button pressed")
        # if read_flag[] == true
        #     schedule(read_task, :STOP, error=true)
        # end
    end


    on(log_button.clicks) do n
        println("log button pressed")
        # if log_flag[] == true
        #     schedule(log_task, :STOP, error=true)
        # end
    end

    on(clear_button.clicks) do n
        empty!(ax1)
        empty!(ax2)
        empty!(ax3)
    end
end

function reset_plot(gui::Gui)

    # clear axes
    empty!(gui.ax1)
    empty!(gui.ax2)
    empty!(gui.ax3)

    points_x = Observable(Point2f[])
    points_y = Observable(Point2f[])
    points_z = Observable(Point2f[])

    gui_data = GuiData(points_x, points_y, points_z)

    # # add line plot
    lines!(gui.ax1, gui_data.points_x, color=:black)
    lines!(gui.ax2, gui_data.points_y, color=:black)
    lines!(gui.ax3, gui_data.points_z, color=:black)

    return gui_data
end

function plot_gyro(gui_data::GuiData, i::Integer, sample)
    # push data to plot buffer
    gui_data.points_x[] = push!(gui_data.points_x[], [(i / 1000) sample[1]])
    gui_data.points_y[] = push!(gui_data.points_y[], [(i / 1000) sample[2]])
    gui_data.points_z[] = push!(gui_data.points_z[], [(i / 1000) sample[3]])
end

