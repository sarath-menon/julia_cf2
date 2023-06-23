using GLMakie
GLMakie.activate!(inline=false)
## 

f = Figure()
ax = Axis(f[1, 1])
limits!(ax, 0, 120, -4, 4)

x_range = 10

display(f)

## 
points = Observable(Point2f[])
line_plot = lines!(ax, points)

fps = 60
nframes = 120

on(points) do point
    x_rlimit = last(points.val)[1][1]
    println("Latest point is:", x_rlimit)

    if x_rlimit >= x_range
        x_llimit = x_rlimit - x_range
    else
        x_llimit = 0
    end

    limits!(ax, x_llimit, x_rlimit, -4, 4)
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