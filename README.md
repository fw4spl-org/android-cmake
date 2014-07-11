CMake is great, and so is Android. This is a collection of CMake scripts, and
patches for common libraries that may be useful to the Android NDK community.
It is based on experience from porting OpenCV library to Android.

Main goal is to share these scripts so that devs that use CMake as their build
system may easily compile native code for Android.

Also, used by the OpenCV project: http://opencv.org/android

You can set directly set the toolchain in the main CMakeLists.txt of your project like this:
```
set(CROSS_COMPILING OFF CACHE BOOL "Set the toolchain file for cross compilation")

if(CROSS_COMPILING)
    execute_process(COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_SOURCE_DIR}/clean_all.cmake)
    set(CMAKE_TOOLCHAIN_FILE CACHE FILEPATH "Path to the toolchain file")
endif()
```
