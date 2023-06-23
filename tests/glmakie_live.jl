using GLMakie
GLMakie.activate!(inline=false)
## 

f = Figure()
ax = Axis(f[1, 1])
x_range = 10
limits!(ax, 0, x_range, -4, 4)



display(f)

## 
points = Observable(Point2f[])
line_plot = lines!(ax, points)

fps = 30
nframes = 80

on(points) do point
    x_right_limit = last(points.val)[1][1]

    if x_right_limit >= x_range
        x_left_limit = x_right_limit - x_range
    else
        x_left_limit = 0
    end

    limits!(ax, x_left_limit, x_right_limit, -4, 4)
end



for i = 1:nframes
    new_point = randn(1)
    points[] = push!(points[], [i sin(i)])
    sleep(1 / fps) # refreshes the display!
end




##
# clear plot
# delete!(ax, line_plot)
empty!(ax)