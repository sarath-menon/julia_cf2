module julia_cf2
using Revise


rad_per_sample_to_hz(x::Float64) = x / (2 * π)

hz_to_rad_per_sample(x::Float64) = 2 * π * x

dB_to_normal(x::Float64) = 10.0^(x / 20)

normal_to_dB(x::Float64) = 20 * log10.(x)


end # module julia_cf2
