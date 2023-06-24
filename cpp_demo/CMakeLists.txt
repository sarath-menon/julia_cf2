cmake_minimum_required(VERSION 3.14)
project(test_lib VERSION 0.1)
set(CMAKE_CXX_STANDARD 17)

add_library(test_lib SHARED)

target_sources(test_lib PRIVATE test_lib.cpp)
