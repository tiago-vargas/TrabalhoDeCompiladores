cmake_minimum_required(VERSION 3.30)
project(TrabalhoDeCompiladores)

set(CMAKE_CXX_STANDARD 26)

add_executable(TrabalhoDeCompiladores src/main.cpp)

find_package(BISON)
find_package(FLEX)
