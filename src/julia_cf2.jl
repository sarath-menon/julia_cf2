module julia_cf2
using Revise


function rad_per_sample_to_hz(val_rad)
    val_hz = val_rad / (2 * π)
    return val_hz
end

function hz_to_rad_per_sample(val_hz)
    val_rad_per_sec = 2 * π * val_hz
    return val_rad_per_sec
end

function dB_to_normal(val)
    return 10.0^(val / 20)
end

function normal_to_dB(val)
    return 20 * log10.(val)
end


function selva()
    print("ok")
end


end # module julia_cf2
