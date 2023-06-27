struct GyroData1
    ẋ::Float64
    ẏ::Float64
    ż::Float64
end

struct GyroData2
    timestamp::Int64
    ẋ::Float64
    ẏ::Float64
    ż::Float64
end


GyroData = GyroData1

#############################

struct AccData2
    x::Float64
    y::Float64
    z::Float64
end

AccData = AccData2

#############################

struct ImuData3
    timestamp::Int64
    acc::AccData
    gyro::GyroData
end

ImuData = ImuData3