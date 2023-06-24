
import Pkg;
Pkg.activate(@__DIR__);
Pkg.instantiate();
##
using Revise
import julia_cf2
using PyCall
using Printf
using DataStructures
using GLMakie

GLMakie.activate!(inline=false)
##

include("src/tasks/tasks.jl")

schedule(cfread_task)
schedule(main_task)



