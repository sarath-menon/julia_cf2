struct Gui3
    fig::Figure
    ax1::Axis
    ax2::Axis
    ax3::Axis
    x_range::Int32

    points_x::Observable{Vector{Point{2,Float32}}}
    points_y::Observable{Vector{Point{2,Float32}}}
    points_z::Observable{Vector{Point{2,Float32}}}
end

Gui = Gui3

function gui_init()
    fig = Figure()
    ax1 = Axis(fig[1, 1])
    ax2 = Axis(fig[2, 1])
    ax3 = Axis(fig[3, 1])

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

    # # for dynamically updating the axes
    # on(points) do point
    #     x_right_limit = last(points.val)[1][1]
    #     # x_right_limit = 50

    #     if x_right_limit >= x_range
    #         x_left_limit = x_right_limit - x_range
    #     else
    #         x_left_limit = 0
    #     end

    #     limits!(ax, x_left_limit, x_right_limit, -4, 4)
    # end



    gui = Gui(fig, ax1, ax2, ax3, x_range, points_x, points_y, points_z)

    return gui
end

function reset_plot(gui::Gui)

    # clear axes
    empty!(gui.ax1)
    empty!(gui.ax2)
    empty!(gui.ax3)

    # # add line plot
    # gui.points_x = Observable(Point2f[])
    # gui.points_y = Observable(Point2f[])
    # gui.points_z = Observable(Point2f[])

    lines!(gui.ax1, gui.points_x)
    lines!(gui.ax2, gui.points_y)
    lines!(gui.ax3, gui.points_z)
end

function plot_gyro(gui::Gui, i, sample)
    # push data to plot buffer
    gui.points_x[] = push!(gui.points_x[], [(i / 1000) sample[1]])
    gui.points_y[] = push!(gui.points_y[], [(i / 1000) sample[2]])
    gui.points_z[] = push!(gui.points_z[], [(i / 1000) sample[3]])
end

