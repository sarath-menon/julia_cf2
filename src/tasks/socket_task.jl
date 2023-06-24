

include("./../lib/socket_udp.jl")

using Sockets
using Serialization
include("comm_utils.jl")

socket_task = @task begin

    recdata()
end



