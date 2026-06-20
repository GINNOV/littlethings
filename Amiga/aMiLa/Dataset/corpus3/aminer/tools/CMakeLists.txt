cmake_minimum_required(VERSION 3.14.0)
# Generator expression skips Debug/Release/... directories for MSVC
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin/$<0:>)
project(aminer_tools)

# Adhere to GNU filesystem layout conventions
include(GNUInstallDirs)
set (CMAKE_CXX_STANDARD 20)

# MSVC needs a few defines to be GNU compatible
if(MSVC)
	add_compile_definitions(_USE_MATH_DEFINES=1 NOMINMAX=1)
endif()

file(GLOB STRINGS_CONV_src src/*.cpp src/*.c src/*.h src/*.hpp)

add_executable(strings_conv ${STRINGS_CONV_src})
target_include_directories(strings_conv PRIVATE ../deps/ACE/include)

if(MINGW)
	message(STATUS "Building STATIC executables")
	target_link_libraries(strings_conv PUBLIC -static)
endif()
