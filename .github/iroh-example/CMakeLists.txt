cmake_minimum_required(VERSION 3.22)
project(iroh-example LANGUAGES CXX)

find_package(iroh CONFIG REQUIRED)

add_executable(iroh-example main.cpp)
target_compile_features(iroh-example PRIVATE cxx_std_17)
target_link_libraries(iroh-example PRIVATE iroh::iroh_c_ffi)
