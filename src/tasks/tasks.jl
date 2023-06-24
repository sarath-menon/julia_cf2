const duration::Integer = 3
const gyro_cb_len::Integer = 5

samples_channel = Channel{Matrix{Float64}}(100);


include("main_task.jl")
include("cfread_task.jl")
