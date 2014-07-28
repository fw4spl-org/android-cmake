# Introduction

This is a modified version of the taka-no-me toolchain, used for FW4SPL (IRCAD) cross-compiling

## android-cmake 
CMake is great, and so is Android. This is a collection of CMake scripts, and
patches for common libraries that may be useful to the Android NDK community.
It is based on experience from porting OpenCV library to Android.

Main goal is to share these scripts so that devs that use CMake as their build
system may easily compile native code for Android.

Also, used by the OpenCV project: http://opencv.org/android

**Modification:**
- Standalone supprot has been removed
- INSTALL_PREFIX_PATH only need to be adjusted, the other output channels that will be sent automatically from this one
- You can set directly the toolchain in the main CMakeLists.txt of your project like this:
```
set(CROSS_COMPILING OFF CACHE BOOL "Configure cross compilation for Android")

if(CROSS_COMPILING)
    execute_process(COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_SOURCE_DIR}/clean_all.cmake)
    set(CMAKE_TOOLCHAIN_FILE CACHE FILEPATH "Path to the toolchain file")
endif()
```
**Note:**
clean_all.cmake script is used to be sure to remove all cache variables to avoid melting between compilations.

## FW4SPL
FW4SPL is a component-oriented architecture with the notion of role-based programming. FW4SPL consists of a set of cross-platform C++ libraries. For now, FW4SPL focuses on the problem of medical images processing and visualization.

https://code.google.com/p/fw4spl/



