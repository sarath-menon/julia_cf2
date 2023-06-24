# struct LogProfiles
#     lg_stab::PyObject
# end

function send_data(data, port=4444)
    # get ip address of host
    ip_address = getipaddr()

    soc = UDPSocket()

    ret = send(soc, ip_address, port, data)
    if ret == false
        println("Could not send data !")
    end

    #     sleep(0.2);
    close(soc)
end

function recdata(port=4444)
    # get ip address of host
    ip_address = getipaddr()
    port = 4444

    println("IP Address: ", ip_address)

    sock = UDPSocket()

    # IObuffer function to convert object to byte streams
    io = IOBuffer()

    ret = bind(sock, ip_address, port)

    if ret == false
        println("Could not bind to socket !")
        return
    end

    println("Waiting for data")

    while true


        pck = recv(sock)

        # Deserialize function takes stream as parameter
        msg = deserialize(IOBuffer(pck))

        # shutdown the receiver is exit msg is received
        if msg == :exit
            println("Shutting down receiver")
            break
        end

        println("Data received:", msg)
    end

    print("Closing port")
    close(sock)
end


