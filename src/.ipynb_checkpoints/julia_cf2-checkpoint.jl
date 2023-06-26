module julia_cf2
using Revise


rad_per_sample_to_hz(x) = x / (2 * π)

hz_to_rad_per_sample(x) = 2 * π * x

dB_to_normal(x) = 10.0^(x / 20)

normal_to_dB(x) = 20 * log10.(x)


end # module julia_cf2
