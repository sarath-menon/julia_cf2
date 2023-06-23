using GLMakie
GLMakie.activate!(inline=false)

fig = Figure()

ax = Axis(fig[1, 1])
fig[2, 1] = buttongrid = GridLayout(tellwidth=false)

display(fig)


button = Button(fig, label="press")

buttongrid[1, 1] = button

flag = Observable(false)

##
on(button.clicks) do n
    if flag[] == true
        schedule(task1, :STOP, error=true)
    end
    # notify(counts)
end

##

task1 = @async try
    flag[] = true
    for i in 1:20
        println(flag)
        sleep(0.5)
    end

catch
    flag[] = false
    println("Interrupted!")
end

