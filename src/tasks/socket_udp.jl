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