cmake_minimum_required(VERSION 3.10)
project(GeoDB CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_COMPILER "/usr/bin/g++")

# Add the executable target from main.cpp
add_executable(views main.cpp)

set(DBT_LIB_DIR /opt/dbtoaster/lib/dbt_c++)

# Specify include directories
target_include_directories(views PRIVATE ${DBT_LIB_DIR})

# Specify link directories
target_link_directories(views PRIVATE ${DBT_LIB_DIR})

# Link the required library
target_link_libraries(views PRIVATE dbtoaster)

# Set the optimization level for release builds (-O3 flag)
set(CMAKE_CXX_FLAGS_RELEASE "-O3")
set(CMAKE_BUILD_TYPE Release)
