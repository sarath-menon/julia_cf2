import Pkg;
Pkg.activate(@__DIR__);
Pkg.instantiate();
## 
using DSP
using GLMakie
using PyCall
using CSV
using DataFrames

## helper functions

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

## load data

df = CSV.read("./data/gyro_unfiltered.csv", DataFrame);
print(df)

gyro_unfiltered_x = df.gyro_unfiltered_x

# f = Figure()
# ax = Axis(f[1, 1])
# lines!(ax, df.timestamp, gyro_unfiltered_x)
# display(f)
## design butterworth filter 

f_s = 1000 # hz
f_c = 80 # hz

m = 4

responsetype = Lowpass(f_c; fs=f_s)
designmethod = Butterworth(m)

butterworth_filter = digitalfilter(responsetype, designmethod)
H, w_normalized = freqresp(butterworth_filter)

w = w_normalized * f_s
mag = abs.(H)
mag_dB = normal_to_dB(mag)
w_hz = rad_per_sample_to_hz(w)

f = Figure()
ax1 = Axis(f[1, 1])
lines!(ax1, w_hz, mag)
vlines!(ax2, [f_c], color=:red)

display(f)

## Apply filter

gyro_filtered_x = filt(digitalfilter(responsetype, designmethod), gyro_unfiltered_x)

f = Figure()
ax1 = Axis(f[1, 1])

lines!(ax1, df.timestamp, gyro_unfiltered_x)
lines!(ax1, df.timestamp, gyro_filtered_x)

display(f)

# plot periodogram
gyro_unfiltered_x_pg = welch_pgram(gyro_unfiltered_x);
gyro_filtered_x_pg = welch_pgram(gyro_filtered_x);

# f = Figure()
ax2 = Axis(f[2, 1])

lines!(ax2, gyro_unfiltered_x_pg.freq, gyro_unfiltered_x_pg.power)
lines!(ax2, gyro_filtered_x_pg.freq, gyro_filtered_x_pg.power)
display(f)

## CMSIS DSP 

cmsisdsp = pyimport("cmsisdsp")

# instance of fixed-point Biquad cascade filter
biquadQ31 = cmsisdsp.arm_biquad_casd_df1_inst_q31()

# get second order sections 
sos = convert(SecondOrderSections, digitalfilter(responsetype, designmethod));


### create biquad_filter
sos_1 = Biquad(4.41270375e-04, 8.82540750e-04, 4.41270375e-04, 1.76499453e+00, -8.11198051e-01)
sos_2 = Biquad(1.00000000e+00, 2.00000000e+00, 1.00000000e+00, 1.70486679e+00, -9.20715613e-01)

biquad_vec = [sos_1, sos_2]
sos = SecondOrderSections(biquad_vec, 1)