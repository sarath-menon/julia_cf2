using GLMakie
GLMakie.activate!(inline=false)
## 

f = Figure()
ax = Axis(f[1, 1])
limits!(ax, 0, 10, -4, 4)

display(f)

## 
points = Observable(Point2f[])
line_plot = lines!(ax, points)

fps = 60
nframes = 120

for i = 1:nframes
    new_point = randn(1)
    points[] = push!(points[], [i sin(i)])
    sleep(1 / fps) # refreshes the display!
end

##
# clear plot
# delete!(ax, line_plot)
empty!(ax)