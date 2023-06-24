module julia_cf2
using Revise


rad_per_sample_to_hz(x::Real) = x / (2 * π)

hz_to_rad_per_sample(x::Real) = 2 * π * x

dB_to_normal(x::Real) = 10.0^(x / 20)

normal_to_dB(x::Real) = 20 * log10.(x)


end # module julia_cf2
