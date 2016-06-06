# Copyright (c) 2010-2011, Ethan Rublee
# Copyright (c) 2011-2014, Andrey Kamaev
# Copyright (c) 2016,      Andrew Gunnerson
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1.  Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#
# 2.  Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions and the following disclaimer in the documentation
#     and/or other materials provided with the distribution.
#
# 3.  Neither the name of the copyright holder nor the names of its
#     contributors may be used to endorse or promote products derived from this
#     software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# ------------------------------------------------------------------------------
#  Android CMake toolchain file, for use with the Android NDK r5-r10
#  Requires cmake 2.6.3 or newer (2.8.5 or newer is recommended).
#  See home page: https://github.com/taka-no-me/android-cmake
#
#  The file is mantained by the OpenCV project. The latest version can be get at
#  http://code.opencv.org/projects/opencv/repository/revisions/master/changes/android/android.toolchain.cmake
#
#  Options (can be set as cmake parameters: -D<option_name>=<value>):
#    ANDROID_NDK=/opt/android-ndk - path to the NDK root.
#      Can be set as environment variable. Can be set only at first cmake run.
#
#
#    ANDROID_ABI=armeabi-v7a - specifies the target Application Binary
#      Interface (ABI). This option nearly matches to the APP_ABI variable
#      used by ndk-build tool from Android NDK.
#
#      Possible targets are:
#        "armeabi" - matches to the NDK ABI with the same name.
#           See ${ANDROID_NDK}/docs/CPU-ARCH-ABIS.html for the documentation.
#        "armeabi-v7a" - matches to the NDK ABI with the same name.
#           See ${ANDROID_NDK}/docs/CPU-ARCH-ABIS.html for the documentation.
#        "armeabi-v7a with NEON" - same as armeabi-v7a, but
#            sets NEON as floating-point unit
#        "armeabi-v7a with VFPV3" - same as armeabi-v7a, but
#            sets VFPV3 as floating-point unit (has 32 registers instead of 16).
#        "armeabi-v6 with VFP" - tuned for ARMv6 processors having VFP.
#        "arm64-v8a" - matches to the NDK ABI with the same name.
#           See ${ANDROID_NDK}/docs/CPU-ARCH-ABIS.html for the documentation.
#        "x86" - matches to the NDK ABI with the same name.
#            See ${ANDROID_NDK}/docs/CPU-ARCH-ABIS.html for the documentation.
#        "x86_64" - matches to the NDK ABI with the same name.
#            See ${ANDROID_NDK}/docs/CPU-ARCH-ABIS.html for the documentation.
#        "mips" - matches to the NDK ABI with the same name.
#            See ${ANDROID_NDK}/docs/CPU-ARCH-ABIS.html for the documentation.
#        "mips64" - matches to the NDK ABI with the same name.
#            See ${ANDROID_NDK}/docs/CPU-ARCH-ABIS.html for the documentation.
#
#    ANDROID_NATIVE_API_LEVEL=android-9 - level of Android API compile for.
#      Option is read-only when standalone toolchain is used.
#
#    ANDROID_TOOLCHAIN_NAME=arm-linux-androideabi-4.9 - the name of compiler
#      toolchain to be used. The list of possible values depends on the NDK
#      version. For NDK r10c the possible values are:
#        * aarch64-linux-android-4.9
#        * aarch64-linux-android-clang3.4
#        * aarch64-linux-android-clang3.5
#        * arm-linux-androideabi-4.6
#        * arm-linux-androideabi-4.8
#        * arm-linux-androideabi-4.9
#        * arm-linux-androideabi-clang3.4
#        * arm-linux-androideabi-clang3.5
#        * llvm-3.4
#        * llvm-3.5
#        * mips64el-linux-android-4.9
#        * mips64el-linux-android-clang3.4
#        * mips64el-linux-android-clang3.5
#        * mipsel-linux-android-4.6
#        * mipsel-linux-android-4.8
#        * mipsel-linux-android-4.9
#        * mipsel-linux-android-clang3.4
#        * mipsel-linux-android-clang3.5
#        * x86_64-4.9
#        * x86_64-clang3.4
#        * x86_64-clang3.5
#        * x86-4.6
#        * x86-4.8
#        * x86-4.9
#        * x86-clang3.4
#        * x86-clang3.5
#
#    ANDROID_FORCE_ARM_BUILD=OFF - set ON to generate 32-bit ARM instructions
#      instead of Thumb. Is not available for "x86" (inapplicable) and
#      "armeabi-v6 with VFP" (is forced to be ON) ABIs.
#
#    ANDROID_NO_UNDEFINED=ON - set ON to show all undefined symbols as linker
#      errors even if they are not used.
#
#    ANDROID_SO_UNDEFINED=OFF - set ON to allow undefined symbols in shared
#      libraries. Automatically turned for NDK r5x and r6x due to GLESv2
#      problems.
#
#    LIBRARY_OUTPUT_PATH_ROOT=${CMAKE_SOURCE_DIR} - where to output binary
#      files. See additional details below.
#
#    ANDROID_SET_OBSOLETE_VARIABLES=ON - if set, then toolchain defines some
#      obsolete variables which were used by previous versions of this file for
#      backward compatibility.
#
#    ANDROID_STL=gnustl_static - specify the runtime to use.
#
#      Possible values are:
#        none           -> Do not configure the runtime.
#        system         -> Use the default minimal system C++ runtime library.
#                          Implies -fno-rtti -fno-exceptions.
#                          Is not available for standalone toolchain.
#        system_re      -> Use the default minimal system C++ runtime library.
#                          Implies -frtti -fexceptions.
#                          Is not available for standalone toolchain.
#        gabi++_static  -> Use the GAbi++ runtime as a static library.
#                          Implies -frtti -fno-exceptions.
#                          Available for NDK r7 and newer.
#                          Is not available for standalone toolchain.
#        gabi++_shared  -> Use the GAbi++ runtime as a shared library.
#                          Implies -frtti -fno-exceptions.
#                          Available for NDK r7 and newer.
#                          Is not available for standalone toolchain.
#        stlport_static -> Use the STLport runtime as a static library.
#                          Implies -fno-rtti -fno-exceptions for NDK before r7.
#                          Implies -frtti -fno-exceptions for NDK r7 and newer.
#                          Is not available for standalone toolchain.
#        stlport_shared -> Use the STLport runtime as a shared library.
#                          Implies -fno-rtti -fno-exceptions for NDK before r7.
#                          Implies -frtti -fno-exceptions for NDK r7 and newer.
#                          Is not available for standalone toolchain.
#        gnustl_static  -> Use the GNU STL as a static library.
#                          Implies -frtti -fexceptions.
#        gnustl_shared  -> Use the GNU STL as a shared library.
#                          Implies -frtti -fno-exceptions.
#                          Available for NDK r7b and newer.
#                          Silently degrades to gnustl_static if not available.
#        c++_static     -> Use the LLVM libc++ runtime as a static library.
#                          Implies -frtti -fexceptions.
#        c++_shared     -> Use the LLVM libc++ runtime as a shared library.
#                          Implies -frtti -fexceptions.
#
#    ANDROID_STL_FORCE_FEATURES=ON - turn rtti and exceptions support based on
#      chosen runtime. If disabled, then the user is responsible for settings
#      these options.
#
# ------------------------------------------------------------------------------

cmake_minimum_required( VERSION 2.6.3 )

set(ANDROID_TOOLCHAIN_NAME "arm-linux-androideabi-clang3.6" CACHE STRING "Name of toolchain to use within the NDK")
# set(ANDROID_NDK_RELEASE_NUM 11000 CACHE VALUES "NDK r version")

#################### Macro Definitions ####################
# List filer
macro( listFilter LIST regex )
    
 if( ${LIST} )
  foreach( VAL ${${LIST}} )
   if( VAL MATCHES "${regex}" )
    list( REMOVE_ITEM ${LIST} "${VAL}" )
   endif()
  endforeach()
 endif()
 
endmacro()

# Init variable
macro( initVariable VAR_NAME )
    
 set( TEST_PATH 0 )
 
 foreach( CURRENT_VAR ${ARGN} )
  if( CURRENT_VAR STREQUAL "PATH" )
   set( TEST_PATH 1 )
   break()
  endif()
 endforeach()
 
 if( TEST_PATH AND NOT EXISTS "${${VAR_NAME}}" )
  unset( ${VAR_NAME} CACHE )
 endif()
 if( "${${VAR_NAME}}" STREQUAL "" )
  set( VALS 0 )
  foreach( CURRENT_VAR ${ARGN} )
   if( CURRENT_VAR STREQUAL "VALUES" )
    set( VALS 1 )
   elseif( NOT CURRENT_VAR STREQUAL "PATH" )
    set( OBSOLETE 0 )
    if( CURRENT_VAR MATCHES "^OBSOLETE_.*$" )
     string( REPLACE "OBSOLETE_" "" CURRENT_VAR "${CURRENT_VAR}" )
     set( OBSOLETE 1 )
    endif()
    if( CURRENT_VAR MATCHES "^ENV_.*$" )
     string( REPLACE "ENV_" "" CURRENT_VAR "${CURRENT_VAR}" )
     set( VAL "$ENV{${CURRENT_VAR}}" )
    elseif( DEFINED ${CURRENT_VAR} )
     set( VAL "${${CURRENT_VAR}}" )
    else()
     if( VALS )
      set( VAL "${CURRENT_VAR}" )
     else()
      set( VAL "" )
     endif()
    endif()
    if( NOT "${VAL}" STREQUAL "" )
     if( TEST_PATH )
      if( EXISTS "${VAL}" )
       file( TO_CMAKE_PATH "${VAL}" ${VAR_NAME} )
       if( OBSOLETE AND NOT CMAKE_IN_TRY_COMPILE )
        message( WARNING "Using value of obsolete variable ${CURRENT_VAR} as initial value for ${VAR_NAME}. Please note, that ${CURRENT_VAR} can be completely removed in future versions of the toolchain." )
       endif()
       break()
      endif()
     else()
      set( ${VAR_NAME} "${VAL}" )
       if( OBSOLETE AND NOT CMAKE_IN_TRY_COMPILE )
        message( WARNING "Using value of obsolete variable ${CURRENT_VAR} as initial value for ${VAR_NAME}. Please note, that ${CURRENT_VAR} can be completely removed in future versions of the toolchain." )
       endif()
      break()
     endif()
    endif()
   endif()
  endforeach()
  unset( VAL )
  unset( VALS )
  unset( OBSOLETE )
 elseif( TEST_PATH )
  file( TO_CMAKE_PATH "${${VAR_NAME}}" ${VAR_NAME} )
 endif()
 unset( TEST_PATH )
 
endmacro()

# Detect native API Level
macro( detectNativeApiLevel CURRENT_VAR CURRENT_PATH )
    
 set( NDK_API_LEVEL_REGEX "^[\t ]*#define[\t ]+__ANDROID_API__[\t ]+([0-9]+)[\t ]*$" )
 
 file( STRINGS ${CURRENT_PATH} API_FILE_CONTENT REGEX "${NDK_API_LEVEL_REGEX}" )
 if( NOT API_FILE_CONTENT )
  message( SEND_ERROR "Could not get Android native API level. Probably you have specified invalid level value, or your copy of NDK/toolchain is broken." )
 endif()
 
 string( REGEX REPLACE "${NDK_API_LEVEL_REGEX}" "\\1" ${CURRENT_VAR} "${API_FILE_CONTENT}" )
 unset( API_FILE_CONTENT )
 unset( NDK_API_LEVEL_REGEX )
endmacro()

# Detect toolchain machine name
macro( detectToolchainMachineName CURRENT_VAR ROOT )
 if( EXISTS "${ROOT}" )
  file( GLOB GCC_PATH RELATIVE "${ROOT}/bin/" "${ROOT}/bin/*-gcc${TOOL_OS_SUFFIX}" )
  listFilter( GCC_PATH "^[.].*" )
  list( LENGTH GCC_PATH GCC_PATHsCount )
  if( NOT GCC_PATHsCount EQUAL 1  AND NOT CMAKE_IN_TRY_COMPILE )
   message( WARNING "Could not determine machine name for compiler from ${ROOT}" )
   set( ${CURRENT_VAR} "" )
  else()
   get_filename_component( GCC_NAME "${GCC_PATH}" NAME_WE )
   string( REPLACE "-gcc" "" ${CURRENT_VAR} "${GCC_NAME}" )
  endif()
  unset( GCC_PATH )
  unset( GCC_PATHsCount )
  unset( GCC_NAME )
 else()
  set( ${CURRENT_VAR} "" )
 endif()
 
endmacro()

# glob NDK toolchain search  
macro( globNdkToolchains AVAILABLE_TOOLCHAIN_VAR AVAIBLE_TOOLCHAINS_LIST TOOLCHAIN_SUBPATH )
    # message( FATAL_ERROR "ANDROID_NDK_RELEASE_NUM = ${ANDROID_NDK_RELEASE_NUM}")
    foreach( CURRENT_TOOLCHAIN ${${AVAIBLE_TOOLCHAINS_LIST}} )
        if( "${CURRENT_TOOLCHAIN}" MATCHES "-clang3[.][0-9]$" AND NOT EXISTS "${ANDROID_NDK_TOOLCHAINS_PATH}/${CURRENT_TOOLCHAIN}${TOOLCHAIN_SUBPATH}" )
            # if( ANDROID_NDK_RELEASE_NUM LESS 11000 )
                # string( REGEX REPLACE "-clang3[.][0-9]$" "-4.6" GCC_TOOLCHAIN "${CURRENT_TOOLCHAIN}" )
            # else()
                string( REGEX REPLACE "-clang3[.][0-9]$" "-4.9" GCC_TOOLCHAIN "${CURRENT_TOOLCHAIN}" )
            # endif()
        else()
            set( GCC_TOOLCHAIN "${CURRENT_TOOLCHAIN}" )
        endif()
        detectToolchainMachineName( MACHINE "${ANDROID_NDK_TOOLCHAINS_PATH}/${GCC_TOOLCHAIN}${TOOLCHAIN_SUBPATH}" )
        if( MACHINE )
            string( REGEX MATCH "[0-9]+[.][0-9]+([.][0-9x]+)?$" VERSION "${GCC_TOOLCHAIN}" )

            if( MACHINE MATCHES i686 )
                set( ARCH "x86" )
            elseif( MACHINE MATCHES x86_64 )
                set( ARCH "x86_64" )
            elseif( MACHINE MATCHES arm )
                set( ARCH "arm" )
            elseif( MACHINE MATCHES aarch64 )
                set( ARCH "arm64" )
            elseif( MACHINE MATCHES mipsel ) 
                set( ARCH "mipsel" )
            elseif( MACHINE MATCHES mips64el ) 
                set( ARCH "mips64el" )
            endif()
   
            list( APPEND AVAILABLE_TOOLCHAIN_MACHINES "${MACHINE}" )
            list( APPEND AVAILABLE_TOOLCHAIN_ARCHS "${ARCH}" )
            list( APPEND AVAILABLE_TOOLCHAIN_COMPILER_VERSION "${VERSION}" )
            list( APPEND ${AVAILABLE_TOOLCHAIN_VAR} "${CURRENT_TOOLCHAIN}" )
        endif()
        unset( GCC_TOOLCHAIN )
    endforeach()
endmacro()

# macro to find packages on the host OS
macro( find_host_package )
    set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
    set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
    set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )
    if( CMAKE_HOST_WIN32 )
        SET( WIN32 1 )
        SET( UNIX )
    elseif( CMAKE_HOST_APPLE )
        SET( APPLE 1 )
        SET( UNIX )
    endif()
    find_package( ${ARGN} )
    SET( WIN32 )
    SET( APPLE )
    SET( UNIX 1 )
    set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
    set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
    set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
endmacro()


# macro to find programs on the host OS
macro( find_host_program )
    set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
    set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER )
    set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER )
    if( CMAKE_HOST_WIN32 )
        SET( WIN32 1 )
        SET( UNIX )
    elseif( CMAKE_HOST_APPLE )
        SET( APPLE 1 )
        SET( UNIX )
    endif()
    find_program( ${ARGN} )
    SET( WIN32 )
    SET( APPLE )
    SET( UNIX 1 )
    set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
    set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
    set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )
endmacro()

# get the abi raw name
macro( ANDROID_GET_ABI_RAWNAME TOOLCHAIN_FLAG VAR )
    if( "${TOOLCHAIN_FLAG}" STREQUAL "ARMEABI" )
        set( ${VAR} "armeabi" )
    elseif( "${TOOLCHAIN_FLAG}" STREQUAL "ARM64_V8A" )
        set( ${VAR} "arm64-v8a" )
    elseif( "${TOOLCHAIN_FLAG}" STREQUAL "ARMEABI_V7A" )
        set( ${VAR} "armeabi-v7a" )
    elseif( "${TOOLCHAIN_FLAG}" STREQUAL "X86" )
        set( ${VAR} "x86" )
    elseif( "${TOOLCHAIN_FLAG}" STREQUAL "X86_64" )
        set( ${VAR} "x86_64" )
    elseif( "${TOOLCHAIN_FLAG}" STREQUAL "MIPS" )
        set( ${VAR} "mips" )
    elseif( "${TOOLCHAIN_FLAG}" STREQUAL "MIPS64" )
        set( ${VAR} "mips64" )
    else()
        set( ${VAR} "unknown" )
    endif()
endmacro()


######################################################


if( DEFINED CMAKE_CROSSCOMPILING )
 # subsequent toolchain loading is not really needed
 return()
endif()

if( CMAKE_TOOLCHAIN_FILE )
 # touch toolchain variable only to suppress "unused variable" warning
endif()

get_property( CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
if( CMAKE_IN_TRY_COMPILE )
 include( "${CMAKE_CURRENT_SOURCE_DIR}/../android.toolchain.config.cmake" OPTIONAL )
endif()

# this one is important
set( CMAKE_SYSTEM_NAME Linux )
# this one not so much
set( CMAKE_SYSTEM_VERSION 1 )

# rpath makes low sence for Android
set( CMAKE_SKIP_RPATH TRUE CACHE BOOL "If set, runtime paths are not added when using shared libraries." )

######################################## 
# set NDK search paths
if(NOT DEFINED ANDROID_NDK_SEARCH_PATHS)
 if( CMAKE_HOST_WIN32 )
  file( TO_CMAKE_PATH "$ENV{PROGRAMFILES}" ANDROID_NDK_SEARCH_PATHS )
  set( ANDROID_NDK_SEARCH_PATHS "${ANDROID_NDK_SEARCH_PATHS}/ANDROID_NDK" "$ENV{SystemDrive}/NVPACK/ANDROID_NDK" )
 else()
  file( TO_CMAKE_PATH "$ENV{HOME}" ANDROID_NDK_SEARCH_PATHS )
  set( ANDROID_NDK_SEARCH_PATHS /opt/android-ndk "${ANDROID_NDK_SEARCH_PATHS}/NVPACK/ANDROID_NDK" )
 endif()
endif()

# set supported android ABIS (Application Binary Interface)
set( ANDROID_SUPPORTED_ABIS_arm "armeabi-v7a;armeabi;armeabi-v7a with NEON;armeabi-v7a with VFPV3;armeabi-v6 with VFP" )
set( ANDROID_SUPPORTED_ABIS_aarch64 "arm64-v8a" )
set( ANDROID_SUPPORTED_ABIS_x86 "x86" )
set( ANDROID_SUPPORTED_ABIS_x86_64 "x86_64" )
set( ANDROID_SUPPORTED_ABIS_mipsel "mips" )
set( ANDROID_SUPPORTED_ABIS_mips64el "mips64" )

# Minimum is set to 9 because lower API level make boost compilation crash
set( ANDROID_DEFAULT_NDK_API_LEVEL 9 )
set( ANDROID_DEFAULT_NDK_API_LEVEL_arm 19 )
set( ANDROID_DEFAULT_NDK_API_LEVEL_x86 19 )
set( ANDROID_DEFAULT_NDK_API_LEVEL_mips 19 )
set( ANDROID_DEFAULT_NDK_API_LEVEL_arm64 21 )
set( ANDROID_DEFAULT_NDK_API_LEVEL_x86_64 21 )
set( ANDROID_DEFAULT_NDK_API_LEVEL_mips64 21 )


# Init NDK varialbe
initVariable( ANDROID_NDK PATH ENV_ANDROID_NDK )

########################################
# fight against cygwin
set( ANDROID_FORBID_SYGWIN TRUE CACHE BOOL "Prevent cmake from working under cygwin and using cygwin tools")
mark_as_advanced( ANDROID_FORBID_SYGWIN )
if( ANDROID_FORBID_SYGWIN )
 if( CYGWIN )
  message( FATAL_ERROR "Android NDK and android-cmake toolchain are not welcome Cygwin. It is unlikely that this cmake toolchain will work under cygwin. But if you want to try then you can set cmake variable ANDROID_FORBID_SYGWIN to FALSE and rerun cmake." )
 endif()
 
 if( CMAKE_HOST_WIN32 )
  # remove cygwin from PATH
  set( __newCURRENT_PATH "$ENV{PATH}")
  listFilter( __newCURRENT_PATH "cygwin" )
  set(ENV{PATH} "${__newCURRENT_PATH}")
  unset(__newCURRENT_PATH)
 endif()
endif()

########################################
# detect current host platform
if( NOT DEFINED ANDROID_NDK_HOST_X64 AND (CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "amd64|x86_64|AMD64" OR CMAKE_HOST_APPLE) )
 set( ANDROID_NDK_HOST_X64 1 CACHE BOOL "Try to use 64-bit compiler toolchain" )
 mark_as_advanced( ANDROID_NDK_HOST_X64 )
endif()

set( TOOL_OS_SUFFIX "" )
if( CMAKE_HOST_APPLE )
 set( ANDROID_NDK_HOST_SYSTEM_NAME "darwin-x86_64" )
 set( ANDROID_NDK_HOST_SYSTEM_NAME2 "darwin-x86" )
elseif( CMAKE_HOST_WIN32 )
 set( ANDROID_NDK_HOST_SYSTEM_NAME "windows-x86_64" )
 set( ANDROID_NDK_HOST_SYSTEM_NAME2 "windows" )
 set( TOOL_OS_SUFFIX ".exe" )
elseif( CMAKE_HOST_UNIX )
 set( ANDROID_NDK_HOST_SYSTEM_NAME "linux-x86_64" )
 set( ANDROID_NDK_HOST_SYSTEM_NAME2 "linux-x86" )
else()
 message( FATAL_ERROR "Cross-compilation on your platform is not supported by this cmake toolchain" )
endif()

if( NOT ANDROID_NDK_HOST_X64 )
 set( ANDROID_NDK_HOST_SYSTEM_NAME ${ANDROID_NDK_HOST_SYSTEM_NAME2} )
endif()

########################################
# remember found paths
if( ANDROID_NDK )
 get_filename_component( ANDROID_NDK "${ANDROID_NDK}" ABSOLUTE )
 set( ANDROID_NDK "${ANDROID_NDK}" CACHE INTERNAL "Path of the Android NDK" FORCE )
 set( BUILD_WITH_ANDROID_NDK True )
 if( EXISTS "${ANDROID_NDK}/RELEASE.TXT" )
  file( STRINGS "${ANDROID_NDK}/RELEASE.TXT" ANDROID_NDK_RELEASE_FULL LIMIT_COUNT 1 REGEX r[0-9]+[a-z]? )
  string( REGEX MATCH r[0-9]+[a-z]? ANDROID_NDK_RELEASE "${ANDROID_NDK_RELEASE_FULL}" )
 elseif( EXISTS "${ANDROID_NDK}/source.properties" )
  file( STRINGS "${ANDROID_NDK}/source.properties" ANDROID_NDK_RELEASE_FULL LIMIT_COUNT 1 REGEX "Pkg\\.Revision" )
  string( REGEX REPLACE "^Pkg\\.Revision *= *(.+)" "\\1" ANDROID_NDK_RELEASE_FULL "${ANDROID_NDK_RELEASE_FULL}" )
  # TODO: Minor version is currently ignored
  string( REGEX REPLACE "^([0-9]+).([0-9]+).*" "r\\1" ANDROID_NDK_RELEASE "${ANDROID_NDK_RELEASE_FULL}" )
 else()
  set( ANDROID_NDK_RELEASE "r1x" )
  set( ANDROID_NDK_RELEASE_FULL "unreleased" )
 endif()
else()
 list(GET ANDROID_NDK_SEARCH_PATHS 0 ANDROID_NDK_SEARCH_PATH)
 message( FATAL_ERROR "Could not find neither Android NDK nor Android standalone toolchain.
    You should either set an environment variable:
      export ANDROID_NDK=~/my-android-ndk
    or
      export ANDROID_STANDALONE_TOOLCHAIN=~/my-android-toolchain
    or put the toolchain or NDK in the default path:
      sudo ln -s ~/my-android-ndk ${ANDROID_NDK_SEARCH_PATH}
      sudo ln -s ~/my-android-toolchain ${ANDROID_STANDALONE_TOOLCHAIN_SEARCH_PATH}" )
endif()

########################################
# android NDK layout
if( BUILD_WITH_ANDROID_NDK )
 if( NOT DEFINED ANDROID_NDK_LAYOUT )
  # try to automatically detect the layout
  if( EXISTS "${ANDROID_NDK}/RELEASE.TXT")
   set( ANDROID_NDK_LAYOUT "RELEASE" )
  elseif( EXISTS "${ANDROID_NDK}/../../linux-x86/toolchain/" )
   set( ANDROID_NDK_LAYOUT "LINARO" )
  elseif( EXISTS "${ANDROID_NDK}/../../gcc/" )
   set( ANDROID_NDK_LAYOUT "ANDROID" )
  endif()
 endif()
 set( ANDROID_NDK_LAYOUT "${ANDROID_NDK_LAYOUT}" CACHE STRING "The inner layout of NDK" )
 mark_as_advanced( ANDROID_NDK_LAYOUT )
 if( ANDROID_NDK_LAYOUT STREQUAL "LINARO" )
  set( ANDROID_NDK_HOST_SYSTEM_NAME ${ANDROID_NDK_HOST_SYSTEM_NAME2} ) # only 32-bit at the moment
  set( ANDROID_NDK_TOOLCHAINS_PATH "${ANDROID_NDK}/../../${ANDROID_NDK_HOST_SYSTEM_NAME}/toolchain" )
  set( ANDROID_NDK_TOOLCHAINS_DEF_PATH "${ANDROID_NDK_TOOLCHAINS_PATH}" )
  set( ANDROID_NDK_TOOLCHAINS_SUBPATH  "" )
  set( ANDROID_NDK_TOOLCHAINS_SUBPATH2 "" )
 elseif( ANDROID_NDK_LAYOUT STREQUAL "ANDROID" )
  set( ANDROID_NDK_HOST_SYSTEM_NAME ${ANDROID_NDK_HOST_SYSTEM_NAME2} ) # only 32-bit at the moment
  set( ANDROID_NDK_TOOLCHAINS_PATH "${ANDROID_NDK}/../../gcc/${ANDROID_NDK_HOST_SYSTEM_NAME}/arm" )
  set( ANDROID_NDK_TOOLCHAINS_DEF_PATH "${ANDROID_NDK_TOOLCHAINS_PATH}" )
  set( ANDROID_NDK_TOOLCHAINS_SUBPATH  "" )
  set( ANDROID_NDK_TOOLCHAINS_SUBPATH2 "" )
 else() # ANDROID_NDK_LAYOUT STREQUAL "RELEASE"
  set( ANDROID_NDK_TOOLCHAINS_PATH "${ANDROID_NDK}/toolchains" )
  # if( ANDROID_NDK_RELEASE_NUM LESS 11000 )
   # set( ANDROID_NDK_TOOLCHAINS_DEF_PATH "${ANDROID_NDK_TOOLCHAINS_PATH}" )
  # else()
   set( ANDROID_NDK_TOOLCHAINS_DEF_PATH "${ANDROID_NDK}/build/core/toolchains" )
  # endif()
  set( ANDROID_NDK_TOOLCHAINS_SUBPATH  "/prebuilt/${ANDROID_NDK_HOST_SYSTEM_NAME}" )
  set( ANDROID_NDK_TOOLCHAINS_SUBPATH2 "/prebuilt/${ANDROID_NDK_HOST_SYSTEM_NAME2}" )
 endif()
 get_filename_component( ANDROID_NDK_TOOLCHAINS_PATH "${ANDROID_NDK_TOOLCHAINS_PATH}" ABSOLUTE )
 
 endif()

########################################
# get all the details about NDK
if( BUILD_WITH_ANDROID_NDK )
 file( GLOB ANDROID_SUPPORTED_NATIVE_API_LEVELS RELATIVE "${ANDROID_NDK}/platforms" "${ANDROID_NDK}/platforms/android-*" )
 string( REPLACE "android-" "" ANDROID_SUPPORTED_NATIVE_API_LEVELS "${ANDROID_SUPPORTED_NATIVE_API_LEVELS}" )
 set( AVAILABLE_TOOLCHAINS "" )
 set( AVAILABLE_TOOLCHAIN_MACHINES "" )
 set( AVAILABLE_TOOLCHAIN_ARCHS "" )
 set( AVAILABLE_TOOLCHAIN_COMPILER_VERSION "" )
 
 if( ANDROID_TOOLCHAIN_NAME AND EXISTS "${ANDROID_NDK_TOOLCHAINS_DEF_PATH}/${ANDROID_TOOLCHAIN_NAME}/" )
  # do not go through all toolchains if we know the name
  set( AVAIBLE_TOOLCHAINS_LIST "${ANDROID_TOOLCHAIN_NAME}" )
  globNdkToolchains( AVAILABLE_TOOLCHAINS AVAIBLE_TOOLCHAINS_LIST "${ANDROID_NDK_TOOLCHAINS_SUBPATH}" )
  if( NOT AVAILABLE_TOOLCHAINS AND NOT ANDROID_NDK_TOOLCHAINS_SUBPATH STREQUAL ANDROID_NDK_TOOLCHAINS_SUBPATH2 )
   globNdkToolchains( AVAILABLE_TOOLCHAINS AVAIBLE_TOOLCHAINS_LIST "${ANDROID_NDK_TOOLCHAINS_SUBPATH2}" )
   if( AVAILABLE_TOOLCHAINS )
    set( ANDROID_NDK_TOOLCHAINS_SUBPATH ${ANDROID_NDK_TOOLCHAINS_SUBPATH2} )
   endif()
  endif()
 endif()
 if( NOT AVAILABLE_TOOLCHAINS )
  file( GLOB AVAIBLE_TOOLCHAINS_LIST RELATIVE "${ANDROID_NDK_TOOLCHAINS_DEF_PATH}" "${ANDROID_NDK_TOOLCHAINS_DEF_PATH}/*" )
  if( AVAILABLE_TOOLCHAINS )
   list(SORT AVAIBLE_TOOLCHAINS_LIST) # we need clang to go after gcc
  endif()
  listFilter( AVAIBLE_TOOLCHAINS_LIST "^[.]" )
  listFilter( AVAIBLE_TOOLCHAINS_LIST "llvm" )
  listFilter( AVAIBLE_TOOLCHAINS_LIST "renderscript" )
  globNdkToolchains( AVAILABLE_TOOLCHAINS AVAIBLE_TOOLCHAINS_LIST "${ANDROID_NDK_TOOLCHAINS_SUBPATH}" )
  if( NOT AVAILABLE_TOOLCHAINS AND NOT ANDROID_NDK_TOOLCHAINS_SUBPATH STREQUAL ANDROID_NDK_TOOLCHAINS_SUBPATH2 )
   globNdkToolchains( AVAILABLE_TOOLCHAINS AVAIBLE_TOOLCHAINS_LIST "${ANDROID_NDK_TOOLCHAINS_SUBPATH2}" )
   if( AVAILABLE_TOOLCHAINS )
    set( ANDROID_NDK_TOOLCHAINS_SUBPATH ${ANDROID_NDK_TOOLCHAINS_SUBPATH2} )
   endif()
  endif()
 endif()
 if( NOT AVAILABLE_TOOLCHAINS )
  message( FATAL_ERROR "Could not find any working toolchain in the NDK. Probably your Android NDK is broken." )
 endif()
endif()

########################################
# build list of available ABIs
set( ANDROID_SUPPORTED_ABIS "" )
set( TOOLCHAIN_ARCH_NAMES ${AVAILABLE_TOOLCHAIN_ARCHS} )
list( REMOVE_DUPLICATES TOOLCHAIN_ARCH_NAMES )
list( SORT TOOLCHAIN_ARCH_NAMES )
foreach( ARCH ${TOOLCHAIN_ARCH_NAMES} )
 list( APPEND ANDROID_SUPPORTED_ABIS ${ANDROID_SUPPORTED_ABIS_${ARCH}} )
endforeach()
unset( TOOLCHAIN_ARCH_NAMES )
if( NOT ANDROID_SUPPORTED_ABIS )
 message( FATAL_ERROR "No one of known Android ABIs is supported by this cmake toolchain." )
endif()

########################################
# choose target AB
initVariable( ANDROID_ABI OBSOLETE_ARM_TARGET OBSOLETE_ARM_TARGETS VALUES ${ANDROID_SUPPORTED_ABIS} )

# verify that target ABI is supported
list( FIND ANDROID_SUPPORTED_ABIS "${ANDROID_ABI}" ANDROID_ABI_INDEX )
if( ANDROID_ABI_INDEX EQUAL -1 )
 string( REPLACE ";" "\", \"" PRINTABLE_ANDROID_SUPPORTED_ABIS  "${ANDROID_SUPPORTED_ABIS}" )
 message( FATAL_ERROR "Specified ANDROID_ABI = \"${ANDROID_ABI}\" is not supported by this cmake toolchain or your NDK/toolchain.
   Supported values are: \"${PRINTABLE_ANDROID_SUPPORTED_ABIS}\"
   " )
endif()
unset( ANDROID_ABI_INDEX )

########################################
# set target ABI options
if( ANDROID_ABI STREQUAL "x86" )
 set( X86 true )
 set( ANDROID_NDK_ABI_NAME "x86" )
 set( ANDROID_ARCH_NAME "x86" )
 set( ANDROID_ARCH_FULLNAME "x86" )
 set( ANDROID_LLVM_TRIPLE "i686-none-linux-android" )
 set( CMAKE_SYSTEM_PROCESSOR "i686" )
elseif( ANDROID_ABI STREQUAL "x86_64" )
  set( X86_64 true )
  set( ANDROID_NDK_ABI_NAME "x86_64" )
  set( ANDROID_ARCH_NAME "x86_64" )
  set( ANDROID_ARCH_FULLNAME "x86_64" )
  set( ANDROID_LLVM_TRIPLE "x86_64-none-linux-android" )
  set( CMAKE_SYSTEM_PROCESSOR "x86_64" )
elseif( ANDROID_ABI STREQUAL "mips" )
 set( MIPS true )
 set( ANDROID_NDK_ABI_NAME "mips" )
 set( ANDROID_ARCH_NAME "mips" )
 set( ANDROID_ARCH_FULLNAME "mipsel" )
 set( ANDROID_LLVM_TRIPLE "mipsel-none-linux-android" )
 set( CMAKE_SYSTEM_PROCESSOR "mips" )
elseif( ANDROID_ABI STREQUAL "mips64" )
  set( MIPS64 true )
  set( ANDROID_NDK_ABI_NAME "mips64" )
  set( ANDROID_ARCH_NAME "mips64" )
  set( ANDROID_ARCH_FULLNAME "mips64el" )
  set( ANDROID_LLVM_TRIPLE "mips64el-none-linux-android" )
  set( CMAKE_SYSTEM_PROCESSOR "mips64" )
elseif( ANDROID_ABI STREQUAL "armeabi" )
 set( ARMEABI true )
 set( ANDROID_NDK_ABI_NAME "armeabi" )
 set( ANDROID_ARCH_NAME "arm" )
 set( ANDROID_ARCH_FULLNAME "arm" )
 set( ANDROID_LLVM_TRIPLE "armv5te-none-linux-androideabi" )
 set( CMAKE_SYSTEM_PROCESSOR "armv5te" )
elseif( ANDROID_ABI STREQUAL "armeabi-v6 with VFP" )
 set( ARMEABI_V6 true )
 set( ANDROID_NDK_ABI_NAME "armeabi" )
 set( ANDROID_ARCH_NAME "arm" )
 set( ANDROID_ARCH_FULLNAME "arm" )
 set( ANDROID_LLVM_TRIPLE "armv5te-none-linux-androideabi" )
 set( CMAKE_SYSTEM_PROCESSOR "armv6" )
 # need always fallback to older platform
 set( ARMEABI true )
elseif( ANDROID_ABI STREQUAL "armeabi-v7a")
 set( ARMEABI_V7A true )
 set( ANDROID_NDK_ABI_NAME "armeabi-v7a" )
 set( ANDROID_ARCH_NAME "arm" )
 set( ANDROID_ARCH_FULLNAME "arm" )
 set( ANDROID_LLVM_TRIPLE "armv7-none-linux-androideabi" )
 set( CMAKE_SYSTEM_PROCESSOR "armv7-a" )
elseif( ANDROID_ABI STREQUAL "armeabi-v7a with VFPV3" )
 set( ARMEABI_V7A true )
 set( ANDROID_NDK_ABI_NAME "armeabi-v7a" )
 set( ANDROID_ARCH_NAME "arm" )
 set( ANDROID_ARCH_FULLNAME "arm" )
 set( ANDROID_LLVM_TRIPLE "armv7-none-linux-androideabi" )
 set( CMAKE_SYSTEM_PROCESSOR "armv7-a" )
 set( VFPV3 true )
elseif( ANDROID_ABI STREQUAL "armeabi-v7a with NEON" )
 set( ARMEABI_V7A true )
 set( ANDROID_NDK_ABI_NAME "armeabi-v7a" )
 set( ANDROID_ARCH_NAME "arm" )
 set( ANDROID_ARCH_FULLNAME "arm" )
 set( ANDROID_LLVM_TRIPLE "armv7-none-linux-androideabi" )
 set( CMAKE_SYSTEM_PROCESSOR "armv7-a" )
 set( VFPV3 true )
 set( NEON true )
elseif( ANDROID_ABI STREQUAL "arm64-v8a" )
  set( ARM64_V8A true )
  set( ANDROID_NDK_ABI_NAME "arm64-v8a" )
  set( ANDROID_ARCH_NAME "arm64" )
  set( ANDROID_ARCH_FULLNAME "arm64" )
  set( ANDROID_LLVM_TRIPLE "armv8-none-linux-androideabi" )
  set( CMAKE_SYSTEM_PROCESSOR "armv8-a" )
  set( VFPV3 true )
  set( NEON true )
else()
 message( SEND_ERROR "Unknown ANDROID_ABI=\"${ANDROID_ABI}\" is specified." )
endif()

########################################
# Add arm options
if( ANDROID_ARCH_NAME STREQUAL "arm" AND NOT ARMEABI_V6 )
 initVariable( ANDROID_FORCE_ARM_BUILD OBSOLETE_FORCE_ARM VALUES OFF )
 set( ANDROID_FORCE_ARM_BUILD ${ANDROID_FORCE_ARM_BUILD} CACHE BOOL "Use 32-bit ARM instructions instead of Thumb-1" FORCE )
 mark_as_advanced( ANDROID_FORCE_ARM_BUILD )
else()
 unset( ANDROID_FORCE_ARM_BUILD CACHE )
endif()

########################################
# choose toolchain
if( ANDROID_TOOLCHAIN_NAME )
 list( FIND AVAILABLE_TOOLCHAINS "${ANDROID_TOOLCHAIN_NAME}" CURRENT_TOOLCHAIN_INDEX )
 if( CURRENT_TOOLCHAIN_INDEX EQUAL -1 )
  list( SORT AVAILABLE_TOOLCHAINS )
  string( REPLACE ";" "\n  * " toolchains_list "${AVAILABLE_TOOLCHAINS}" )
  set( toolchains_list "  * ${toolchains_list}")
  message( FATAL_ERROR "Specified toolchain \"${ANDROID_TOOLCHAIN_NAME}\" is missing in your NDK or broken. Please verify that your NDK is working or select another compiler toolchain.
To configure the toolchain set CMake variable ANDROID_TOOLCHAIN_NAME to one of the following values:\n${toolchains_list}\n" )
 endif()
 list( GET AVAILABLE_TOOLCHAIN_ARCHS ${CURRENT_TOOLCHAIN_INDEX} CURRENT_TOOLCHAIN_ARCH )
 if( NOT CURRENT_TOOLCHAIN_ARCH STREQUAL ANDROID_ARCH_FULLNAME )
  message( SEND_ERROR "Selected toolchain \"${ANDROID_TOOLCHAIN_NAME}\" is not able to compile binaries for the \"${ANDROID_ARCH_NAME}\" platform." )
 endif()
else()
 set( CURRENT_TOOLCHAIN_INDEX -1 )
 set( APPLICABLE_TOOLCHAINS "" )
 set( CURRENT_TOOLCHAIN_MAX_VERSION "0.0.0" )
 list( LENGTH AVAILABLE_TOOLCHAINS TOOLCHAINS_LIST_LENGTH )

 math( EXPR TOOLCHAINS_LIST_LENGTH "${TOOLCHAINS_LIST_LENGTH}-1" )
 foreach( INDEX RANGE ${TOOLCHAINS_LIST_LENGTH} )    
  list( GET AVAILABLE_TOOLCHAIN_ARCHS ${INDEX} CURRENT_TOOLCHAIN_ARCH )
  if( CURRENT_TOOLCHAIN_ARCH STREQUAL ANDROID_ARCH_FULLNAME )
   list( GET AVAILABLE_TOOLCHAIN_COMPILER_VERSION ${INDEX} CURRENT_TOOLCHAIN_VERSION )
   string( REPLACE "x" "99" CURRENT_TOOLCHAIN_VERSION "${CURRENT_TOOLCHAIN_VERSION}")
   if( CURRENT_TOOLCHAIN_VERSION VERSION_GREATER CURRENT_TOOLCHAIN_MAX_VERSION )
    set( CURRENT_TOOLCHAIN_MAX_VERSION "${CURRENT_TOOLCHAIN_VERSION}" )
    set( CURRENT_TOOLCHAIN_INDEX ${INDEX} )
   endif()
  endif()
 endforeach()
 unset( TOOLCHAINS_LIST_LENGTH )
 unset( CURRENT_TOOLCHAIN_MAX_VERSION )
 unset( CURRENT_TOOLCHAIN_VERSION )
endif()
unset( CURRENT_TOOLCHAIN_ARCH )
if( CURRENT_TOOLCHAIN_INDEX EQUAL -1 )
 message( FATAL_ERROR "No one of available compiler toolchains is able to compile for ${ANDROID_ARCH_NAME} platform." )
endif()
list( GET AVAILABLE_TOOLCHAINS ${CURRENT_TOOLCHAIN_INDEX} ANDROID_TOOLCHAIN_NAME )
list( GET AVAILABLE_TOOLCHAIN_MACHINES ${CURRENT_TOOLCHAIN_INDEX} ANDROID_TOOLCHAIN_MACHINE_NAME )
list( GET AVAILABLE_TOOLCHAIN_COMPILER_VERSION ${CURRENT_TOOLCHAIN_INDEX} ANDROID_COMPILER_VERSION )

unset( CURRENT_TOOLCHAIN_INDEX )
unset( AVAILABLE_TOOLCHAINS )
unset( AVAILABLE_TOOLCHAIN_MACHINES )
unset( AVAILABLE_TOOLCHAIN_ARCHS )
unset( AVAILABLE_TOOLCHAIN_COMPILER_VERSION )

########################################
# choose native API level
initVariable( ANDROID_NATIVE_API_LEVEL ENV_ANDROID_NATIVE_API_LEVEL ANDROID_API_LEVEL ENV_ANDROID_API_LEVEL ANDROID_DEFAULT_NDK_API_LEVEL_${ANDROID_ARCH_NAME} ANDROID_DEFAULT_NDK_API_LEVEL )

string( REGEX MATCH "[0-9]+" ANDROID_NATIVE_API_LEVEL "${ANDROID_NATIVE_API_LEVEL}" )
# adjust API level
set( REAL_API_LEVEL  ${ANDROID_DEFAULT_NDK_API_LEVEL_${ANDROID_ARCH_NAME}} )
foreach( LEVEL ${ANDROID_SUPPORTED_NATIVE_API_LEVELS} )
 if( NOT LEVEL GREATER ANDROID_NATIVE_API_LEVEL AND NOT LEVEL LESS REAL_API_LEVEL  )
  set( REAL_API_LEVEL  ${LEVEL} )
 endif()
endforeach()
if( REAL_API_LEVEL  AND NOT ANDROID_NATIVE_API_LEVEL EQUAL REAL_API_LEVEL  )
 message( STATUS "Adjusting Android API level 'android-${ANDROID_NATIVE_API_LEVEL}' to 'android-${REAL_API_LEVEL}'")
 set( ANDROID_NATIVE_API_LEVEL ${REAL_API_LEVEL} )
endif()
unset(REAL_API_LEVEL )
# validate
list( FIND ANDROID_SUPPORTED_NATIVE_API_LEVELS "${ANDROID_NATIVE_API_LEVEL}" LEVEL_INDEX )
if( LEVEL_INDEX EQUAL -1 )
 message( SEND_ERROR "Specified Android native API level 'android-${ANDROID_NATIVE_API_LEVEL}' is not supported by your NDK/toolchain." )
else()
 if( BUILD_WITH_ANDROID_NDK )
  detectNativeApiLevel( REAL_API_LEVEL "${ANDROID_NDK}/platforms/android-${ANDROID_NATIVE_API_LEVEL}/arch-${ANDROID_ARCH_NAME}/usr/include/android/api-level.h" )
  if( NOT REAL_API_LEVEL EQUAL ANDROID_NATIVE_API_LEVEL )
   message( SEND_ERROR "Specified Android API level (${ANDROID_NATIVE_API_LEVEL}) does not match to the level found (${REAL_API_LEVEL}). Probably your copy of NDK is broken." )
  endif()
  unset( REAL_API_LEVEL )
 endif()
 set( ANDROID_NATIVE_API_LEVEL "${ANDROID_NATIVE_API_LEVEL}" CACHE STRING "Android API level for native code" FORCE )
 if( CMAKE_VERSION VERSION_GREATER "2.8" )
  list( SORT ANDROID_SUPPORTED_NATIVE_API_LEVELS )
  set_property( CACHE ANDROID_NATIVE_API_LEVEL PROPERTY STRINGS ${ANDROID_SUPPORTED_NATIVE_API_LEVELS} )
 endif()
endif()
unset( LEVEL_INDEX )

set (ANDROID_ARCH_NAME "${ANDROID_ARCH_NAME}" CACHE INTERNAL "The arch name for Android." FORCE )


########################################
# remember target ABI
set( ANDROID_ABI "${ANDROID_ABI}" CACHE STRING "The target ABI for Android. If arm, then armeabi-v7a is recommended for hardware floating point." FORCE )
if( CMAKE_VERSION VERSION_GREATER "2.8" )
 list( SORT ANDROID_SUPPORTED_ABIS_${ANDROID_ARCH_FULLNAME} )
 set_property( CACHE ANDROID_ABI PROPERTY STRINGS ${ANDROID_SUPPORTED_ABIS_${ANDROID_ARCH_FULLNAME}} )
endif()

########################################
# runtime choice (STL, rtti, exceptions)
if( NOT ANDROID_STL )
 # honor legacy ANDROID_USE_STLPORT
 if( DEFINED ANDROID_USE_STLPORT )
  if( ANDROID_USE_STLPORT )
   set( ANDROID_STL stlport_static )
  endif()
  message( WARNING "You are using an obsolete variable ANDROID_USE_STLPORT to select the STL variant. Use -DANDROID_STL=stlport_static instead." )
 endif()
 if( NOT ANDROID_STL )
  # set( ANDROID_STL gnustl_shared )
  set( ANDROID_STL c++_shared )
 endif()
endif()
set( ANDROID_STL "${ANDROID_STL}" CACHE STRING "C++ runtime" )
set( ANDROID_STL_FORCE_FEATURES ON CACHE BOOL "automatically configure rtti and exceptions support based on C++ runtime" )
mark_as_advanced( ANDROID_STL ANDROID_STL_FORCE_FEATURES )

if( BUILD_WITH_ANDROID_NDK )
 # if( NOT "${ANDROID_STL}" MATCHES "^(none|system|system_re|gabi\\+\\+_static|gabi\\+\\+_shared|stlport_static|stlport_shared|gnustl_static|gnustl_shared)$")
if( NOT "${ANDROID_STL}" MATCHES "^(none|system|system_re|gabi\\+\\+_static|gabi\\+\\+_shared|stlport_static|stlport_shared|gnustl_static|gnustl_shared|c\\+\\+_static|c\\+\\+_shared)$") 
 message( FATAL_ERROR "ANDROID_STL is set to invalid value \"${ANDROID_STL}\".
The possible values are:
  none           -> Do not configure the runtime.
  system         -> Use the default minimal system C++ runtime library.
  system_re      -> Same as system but with rtti and exceptions.
  gabi++_static  -> Use the GAbi++ runtime as a static library.
  gabi++_shared  -> Use the GAbi++ runtime as a shared library.
  stlport_static -> Use the STLport runtime as a static library.
  stlport_shared -> Use the STLport runtime as a shared library.
  gnustl_static  -> (default) Use the GNU STL as a static library.
  gnustl_shared  -> Use the GNU STL as a shared library.
  c++_static     -> Use LLVM libc++ runtime as static library.
  c++_shared     -> Use LLVM libc++ runtime as shared library.
" )
 endif()
endif()

unset( ANDROID_RTTI )
unset( ANDROID_EXCEPTIONS )
unset( ANDROID_STL_INCLUDE_DIRS )
unset( LIB_STL )
unset( LIB_SUPCXX )

########################################
# NDK r7 warning
if( NOT CMAKE_IN_TRY_COMPILE AND ANDROID_NDK_RELEASE STREQUAL "r7b" AND ARMEABI_V7A AND NOT VFPV3 AND ANDROID_STL MATCHES "gnustl" )
 message( WARNING  "The GNU STL armeabi-v7a binaries from NDK r7b can crash non-NEON devices. The files provided with NDK r7b were not configured properly, resulting in crashes on Tegra2-based devices and others when trying to use certain floating-point functions (e.g., cosf, sinf, expf).
You are strongly recommended to switch to another NDK release.
" )
endif()

########################################
# NDK r6 patch
if( NOT CMAKE_IN_TRY_COMPILE AND X86 AND ANDROID_STL MATCHES "gnustl" AND ANDROID_NDK_RELEASE STREQUAL "r6" )
  message( WARNING  "The x86 system header file from NDK r6 has incorrect definition for ptrdiff_t. You are recommended to upgrade to a newer NDK release or manually patch the header:
See https://android.googlesource.com/platform/development.git f907f4f9d4e56ccc8093df6fee54454b8bcab6c2
  diff --git a/ndk/platforms/android-9/arch-x86/include/machine/_types.h b/ndk/platforms/android-9/arch-x86/include/machine/_types.h
  index 5e28c64..65892a1 100644
  --- a/ndk/platforms/android-9/arch-x86/include/machine/_types.h
  +++ b/ndk/platforms/android-9/arch-x86/include/machine/_types.h
  @@ -51,7 +51,11 @@ typedef long int       ssize_t;
   #endif
   #ifndef _PTRDIFF_T
   #define _PTRDIFF_T
  -typedef long           ptrdiff_t;
  +#  ifdef __ANDROID__
  +     typedef int            ptrdiff_t;
  +#  else
  +     typedef long           ptrdiff_t;
  +#  endif
   #endif
" )
endif()

########################################
# Clang specific setup
if( "${ANDROID_TOOLCHAIN_NAME}" MATCHES "-clang3[.][0-9]?$" )
 string( REGEX MATCH "3[.][0-9]$" ANDROID_CLANG_VERSION "${ANDROID_TOOLCHAIN_NAME}")
 string( REGEX REPLACE "-clang${ANDROID_CLANG_VERSION}$" "-4.9" ANDROID_GCC_TOOLCHAIN_NAME "${ANDROID_TOOLCHAIN_NAME}" )
 # string( REGEX REPLACE "-clang${ANDROID_CLANG_VERSION}$" "-4.6" ANDROID_GCC_TOOLCHAIN_NAME "${ANDROID_TOOLCHAIN_NAME}" )
 # if( ANDROID_NDK_RELEASE_NUM LESS 11000 )
  # set( ANDROID_CLANG_TOOLCHAIN_ROOT "${ANDROID_NDK_TOOLCHAINS_PATH}/llvm-${ANDROID_CLANG_VERSION}${ANDROID_NDK_TOOLCHAINS_SUBPATH}" )
 # else()
  set( ANDROID_CLANG_TOOLCHAIN_ROOT "${ANDROID_NDK_TOOLCHAINS_PATH}/llvm${ANDROID_NDK_TOOLCHAINS_SUBPATH}" )
 # endif()

 if( NOT EXISTS "${ANDROID_CLANG_TOOLCHAIN_ROOT}/bin/clang${TOOL_OS_SUFFIX}" )
  unset( ANDROID_CLANG_TOOLCHAIN_ROOT )
  message( FATAL_ERROR "Could not find the Clang compiler driver" )
 endif()
 set( ANDROID_COMPILER_IS_CLANG 1 )
else()
 set( ANDROID_GCC_TOOLCHAIN_NAME "${ANDROID_TOOLCHAIN_NAME}" )
 unset( ANDROID_COMPILER_IS_CLANG CACHE )
endif()

string( REPLACE "." "" CLANG_NAME "clang${ANDROID_CLANG_VERSION}" )
if( NOT EXISTS "${ANDROID_CLANG_TOOLCHAIN_ROOT}/bin/${CLANG_NAME}${TOOL_OS_SUFFIX}" )
 set( CLANG_NAME "clang" )
endif()

########################################
# setup paths and STL for NDK
if( BUILD_WITH_ANDROID_NDK )
 set( ANDROID_TOOLCHAIN_ROOT "${ANDROID_NDK_TOOLCHAINS_PATH}/${ANDROID_GCC_TOOLCHAIN_NAME}${ANDROID_NDK_TOOLCHAINS_SUBPATH}" )
 set( ANDROID_SYSROOT "${ANDROID_NDK}/platforms/android-${ANDROID_NATIVE_API_LEVEL}/arch-${ANDROID_ARCH_NAME}" )

 if( ANDROID_STL STREQUAL "none" )
  # do nothing
 elseif( ANDROID_STL STREQUAL "system" )
  set( ANDROID_RTTI             OFF )
  set( ANDROID_EXCEPTIONS       OFF )
  set( ANDROID_STL_INCLUDE_DIRS "${ANDROID_NDK}/sources/cxx-stl/system/include" )
 elseif( ANDROID_STL STREQUAL "system_re" )
  set( ANDROID_RTTI             ON )
  set( ANDROID_EXCEPTIONS       ON )
  set( ANDROID_STL_INCLUDE_DIRS "${ANDROID_NDK}/sources/cxx-stl/system/include" )
 elseif( ANDROID_STL MATCHES "gabi" )
  if( ANDROID_NDK_RELEASE STRLESS "r7" )
   message( FATAL_ERROR "gabi++ is not awailable in your NDK. You have to upgrade to NDK r7 or newer to use gabi++.")
  endif()
  set( ANDROID_RTTI             ON )
  set( ANDROID_EXCEPTIONS       OFF )
  set( ANDROID_STL_INCLUDE_DIRS "${ANDROID_NDK}/sources/cxx-stl/gabi++/include" )
  set( LIB_STL                 "${ANDROID_NDK}/sources/cxx-stl/gabi++/libs/${ANDROID_NDK_ABI_NAME}/libgabi++_static.a" )
 elseif( ANDROID_STL MATCHES "stlport" )
  if( NOT ANDROID_NDK_RELEASE STRLESS "r8d" )
   set( ANDROID_EXCEPTIONS       ON )
  else()
   set( ANDROID_EXCEPTIONS       OFF )
  endif()
  if( ANDROID_NDK_RELEASE STRLESS "r7" )
   set( ANDROID_RTTI            OFF )
  else()
   set( ANDROID_RTTI            ON )
  endif()
  set( ANDROID_STL_INCLUDE_DIRS "${ANDROID_NDK}/sources/cxx-stl/stlport/stlport" )
  set( LIB_STL                 "${ANDROID_NDK}/sources/cxx-stl/stlport/libs/${ANDROID_NDK_ABI_NAME}/libstlport_static.a" )
 elseif( ANDROID_STL MATCHES "gnustl" )
  set( ANDROID_EXCEPTIONS       ON )
  set( ANDROID_RTTI             ON )
  if( EXISTS "${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/${ANDROID_COMPILER_VERSION}" )
   if( ARMEABI_V7A AND ANDROID_COMPILER_VERSION VERSION_EQUAL "4.7" AND ANDROID_NDK_RELEASE STREQUAL "r8d" )
    # gnustl binary for 4.7 compiler is buggy :(
    # TODO: look for right fix
    set( LIB_STL                "${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/4.6" )
   else()
    set( LIB_STL                "${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/${ANDROID_COMPILER_VERSION}" )
   endif()
  else()
   set( LIB_STL                "${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++" )
  endif()
  set( ANDROID_STL_INCLUDE_DIRS "${LIB_STL}/include" "${LIB_STL}/libs/${ANDROID_NDK_ABI_NAME}/include" )
  if( EXISTS "${LIB_STL}/libs/${ANDROID_NDK_ABI_NAME}/libgnustl_static.a" )
   set( LIB_STL                "${LIB_STL}/libs/${ANDROID_NDK_ABI_NAME}/libgnustl_static.a" )
  else()
   set( LIB_STL                "${LIB_STL}/libs/${ANDROID_NDK_ABI_NAME}/libstdc++.a" )
  endif()
  elseif( ANDROID_STL MATCHES "c\\+\\+")
  if( ANDROID_NDK_RELEASE_NUM LESS 9000 ) # before r9
   message( FATAL_ERROR "LLVM c++ is not available in your NDK. You have to upgrade to NDK r9 or newer to use LLVM c++.")
  endif()
  set( ANDROID_EXCEPTIONS       ON )
  set( ANDROID_RTTI             ON )
  set( ANDROID_STL_INCLUDE_DIRS "${ANDROID_NDK}/sources/cxx-stl/llvm-libc++/libcxx/include" "${ANDROID_NDK}/sources/android/support/include"
                                 "${ANDROID_NDK}/sources/cxx-stl/llvm-libc++abi/libcxxabi/include")
  set( LIB_STL                 "${ANDROID_NDK}/sources/cxx-stl/llvm-libc++/libs/${ANDROID_NDK_ABI_NAME}/libc++_static.a" )
 else()
  message( FATAL_ERROR "Unknown runtime: ${ANDROID_STL}" )
 endif()
 # find libsupc++.a - rtti & exceptions
 if( ANDROID_STL STREQUAL "system_re" OR ANDROID_STL MATCHES "gnustl" )
  set( LIB_SUPCXX "${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/${ANDROID_COMPILER_VERSION}/libs/${ANDROID_NDK_ABI_NAME}/libsupc++.a" ) # r8b or newer
  if( NOT EXISTS "${LIB_SUPCXX}" )
   set( LIB_SUPCXX "${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++/libs/${ANDROID_NDK_ABI_NAME}/libsupc++.a" ) # r7-r8
  endif()
  if( NOT EXISTS "${LIB_SUPCXX}" ) # before r7
   if( ARMEABI_V7A )
    if( ANDROID_FORCE_ARM_BUILD )
     set( LIB_SUPCXX "${ANDROID_TOOLCHAIN_ROOT}/${ANDROID_TOOLCHAIN_MACHINE_NAME}/lib/${CMAKE_SYSTEM_PROCESSOR}/libsupc++.a" )
    else()
     set( LIB_SUPCXX "${ANDROID_TOOLCHAIN_ROOT}/${ANDROID_TOOLCHAIN_MACHINE_NAME}/lib/${CMAKE_SYSTEM_PROCESSOR}/thumb/libsupc++.a" )
    endif()
   elseif( ARMEABI AND NOT ANDROID_FORCE_ARM_BUILD )
    set( LIB_SUPCXX "${ANDROID_TOOLCHAIN_ROOT}/${ANDROID_TOOLCHAIN_MACHINE_NAME}/lib/thumb/libsupc++.a" )
   else()
    set( LIB_SUPCXX "${ANDROID_TOOLCHAIN_ROOT}/${ANDROID_TOOLCHAIN_MACHINE_NAME}/lib/libsupc++.a" )
   endif()
  endif()
  if( NOT EXISTS "${LIB_SUPCXX}")
   message( ERROR "Could not find libsupc++.a for a chosen platform. Either your NDK is not supported or is broken.")
  endif()
 endif()
endif()

########################################
# case of shared STL linkage
if( ANDROID_STL MATCHES "shared" AND DEFINED LIB_STL )
 string( REPLACE "_static.a" "_shared.so" LIB_STL "${LIB_STL}" )
 # TODO: check if .so file exists before the renaming
endif()

########################################
# ccache support
initVariable( _ndk_ccache NDK_CCACHE ENV_NDK_CCACHE )
if( _ndk_ccache )
 if( DEFINED NDK_CCACHE AND NOT EXISTS NDK_CCACHE )
  unset( NDK_CCACHE CACHE )
 endif()
 find_program( NDK_CCACHE "${_ndk_ccache}" DOC "The path to ccache binary")
else()
 unset( NDK_CCACHE CACHE )
endif()
unset( _ndk_ccache )

########################################
# setup the cross-compiler
unset(CMAKE_C_COMPILER CACHE)
unset(CMAKE_CXX_COMPILER CACHE)

unset(CMAKE_C_COMPILER_ARG1 CACHE)
unset(CMAKE_CXX_COMPILER_ARG1 CACHE)
    
unset( CMAKE_ASM_COMPILER CACHE )
unset( CMAKE_STRIP        CACHE )
unset( CMAKE_AR           CACHE )
unset( CMAKE_LINKER       CACHE )
unset( CMAKE_NM           CACHE )
unset( CMAKE_OBJCOPY      CACHE )
unset( CMAKE_OBJDUMP      CACHE )
unset( CMAKE_RANLIB       CACHE )

if( NDK_CCACHE AND NOT ANDROID_SYSROOT MATCHES "[ ;\"]" )

    set( CMAKE_C_COMPILER   "${NDK_CCACHE}" CACHE PATH "ccache as C compiler" )
    set( CMAKE_CXX_COMPILER "${NDK_CCACHE}" CACHE PATH "ccache as C++ compiler" )
    if( ANDROID_COMPILER_IS_CLANG )
        set( CMAKE_C_COMPILER_ARG1   "${ANDROID_CLANG_TOOLCHAIN_ROOT}/bin/${CLANG_NAME}${TOOL_OS_SUFFIX}"   CACHE PATH "C compiler")
        set( CMAKE_CXX_COMPILER_ARG1 "${ANDROID_CLANG_TOOLCHAIN_ROOT}/bin/${CLANG_NAME}++${TOOL_OS_SUFFIX}" CACHE PATH "C++ compiler")
    else()
        set( CMAKE_C_COMPILER_ARG1   "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-gcc${TOOL_OS_SUFFIX}" CACHE PATH "C compiler")
        set( CMAKE_CXX_COMPILER_ARG1 "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-g++${TOOL_OS_SUFFIX}" CACHE PATH "C++ compiler")
    endif()
else()
    if( ANDROID_COMPILER_IS_CLANG )
        set( CMAKE_C_COMPILER   "${ANDROID_CLANG_TOOLCHAIN_ROOT}/bin/${CLANG_NAME}${TOOL_OS_SUFFIX}"   CACHE PATH "C compiler")
        set( CMAKE_CXX_COMPILER "${ANDROID_CLANG_TOOLCHAIN_ROOT}/bin/${CLANG_NAME}++${TOOL_OS_SUFFIX}" CACHE PATH "C++ compiler")
    else()
        set( CMAKE_C_COMPILER   "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-gcc${TOOL_OS_SUFFIX}"    CACHE PATH "C compiler" )
        set( CMAKE_CXX_COMPILER "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-g++${TOOL_OS_SUFFIX}"    CACHE PATH "C++ compiler" )
    endif()
endif()

set( CMAKE_ASM_COMPILER "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-gcc${TOOL_OS_SUFFIX}"     CACHE PATH "assembler" )
set( CMAKE_STRIP        "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-strip${TOOL_OS_SUFFIX}"   CACHE PATH "strip" )
set( CMAKE_AR           "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-ar${TOOL_OS_SUFFIX}"      CACHE PATH "archive" )
set( CMAKE_LINKER       "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-ld${TOOL_OS_SUFFIX}"      CACHE PATH "linker" )
set( CMAKE_NM           "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-nm${TOOL_OS_SUFFIX}"      CACHE PATH "nm" )
set( CMAKE_OBJCOPY      "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-objcopy${TOOL_OS_SUFFIX}" CACHE PATH "objcopy" )
set( CMAKE_OBJDUMP      "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-objdump${TOOL_OS_SUFFIX}" CACHE PATH "objdump" )
set( CMAKE_RANLIB       "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_MACHINE_NAME}-ranlib${TOOL_OS_SUFFIX}"  CACHE PATH "ranlib" )

set( _CMAKE_TOOLCHAIN_PREFIX "${ANDROID_TOOLCHAIN_MACHINE_NAME}-" )
if( CMAKE_VERSION VERSION_LESS 2.8.5 )
 set( CMAKE_ASM_COMPILER_ARG1 "-c" )
endif()
if( APPLE )
 find_program( CMAKE_INSTALL_NAME_TOOL NAMES install_name_tool )
 if( NOT CMAKE_INSTALL_NAME_TOOL )
  message( FATAL_ERROR "Could not find install_name_tool, please check your installation." )
 endif()
 mark_as_advanced( CMAKE_INSTALL_NAME_TOOL )
endif()

########################################
# Force set compilers because standard identification works badly for us
include( CMakeForceCompiler )
CMAKE_FORCE_C_COMPILER( "${CMAKE_C_COMPILER}" GNU )
if( ANDROID_COMPILER_IS_CLANG )
    set( CMAKE_C_COMPILER_ID Clang)
endif()
set( CMAKE_C_PLATFORM_ID Linux )
if( ARM64_V8A OR X86_64 OR MIPS64 )
    set( CMAKE_CXX_SIZEOF_DATA_PTR 8 )
else()
    set( CMAKE_CXX_SIZEOF_DATA_PTR 4 )
endif()
set( CMAKE_C_HAS_ISYSROOT 1 )
set( CMAKE_C_COMPILER_ABI ELF )
CMAKE_FORCE_CXX_COMPILER( "${CMAKE_CXX_COMPILER}" GNU )
if( ANDROID_COMPILER_IS_CLANG )
    set( CMAKE_CXX_COMPILER_ID Clang)
endif()
set( CMAKE_CXX_PLATFORM_ID Linux )
if( ARM64_V8A OR X86_64 OR MIPS64 )
    set( CMAKE_CXX_SIZEOF_DATA_PTR 8 )
else()
    set( CMAKE_CXX_SIZEOF_DATA_PTR 4 )
endif()
set( CMAKE_CXX_HAS_ISYSROOT 1 )
set( CMAKE_CXX_COMPILER_ABI ELF )
set( CMAKE_CXX_SOURCE_FILE_EXTENSIONS cc cp cxx cpp CPP c++ C )
# force ASM compiler (required for CMake < 2.8.5)
set( CMAKE_ASM_COMPILER_ID_RUN TRUE )
set( CMAKE_ASM_COMPILER_ID GNU )
set( CMAKE_ASM_COMPILER_WORKS TRUE )
set( CMAKE_ASM_COMPILER_FORCED TRUE )
set( CMAKE_COMPILER_IS_GNUASM 1)
set( CMAKE_ASM_SOURCE_FILE_EXTENSIONS s S asm )

########################################
# flags and definitions
remove_definitions( -DANDROID )
add_definitions( -DANDROID )

if( ANDROID_SYSROOT MATCHES "[ ;\"]" )
 if( CMAKE_HOST_WIN32 )
  # try to convert path to 8.3 form
  file( WRITE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/cvt83.cmd" "@echo %~s1" )
  execute_process( COMMAND "$ENV{ComSpec}" /c "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/cvt83.cmd" "${ANDROID_SYSROOT}"
                   OUTPUT_VARIABLE _CURRENT_PATH OUTPUT_STRIP_TRAILING_WHITESPACE
                   RESULT_VARIABLE __result ERROR_QUIET )
  if( __result EQUAL 0 )
   file( TO_CMAKE_PATH "${_CURRENT_PATH}" ANDROID_SYSROOT )
   set( ANDROID_CXX_FLAGS "--sysroot=${ANDROID_SYSROOT}" )
  else()
   set( ANDROID_CXX_FLAGS "--sysroot=\"${ANDROID_SYSROOT}\"" )
  endif()
 else()
  set( ANDROID_CXX_FLAGS "'--sysroot=${ANDROID_SYSROOT}'" )
 endif()
 if( NOT CMAKE_IN_TRY_COMPILE )
  # quotes can break try_compile and compiler identification
  message(WARNING "Path to your Android NDK (or toolchain) has non-alphanumeric symbols.\nThe build might be broken.\n")
 endif()
else()
 set( ANDROID_CXX_FLAGS "--sysroot=${ANDROID_SYSROOT}" )
endif()

########################################
# NDK flags
if( ARMEABI OR ARMEABI_V7A OR ARM64_V8A)
    set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -fpic -funwind-tables" )
    if( NOT ANDROID_FORCE_ARM_BUILD AND NOT ARMEABI_V6 )
        set( ANDROID_CXX_FLAGS_RELEASE "-mthumb -fomit-frame-pointer -fno-strict-aliasing" )
        set( ANDROID_CXX_FLAGS_DEBUG   "-marm -fno-omit-frame-pointer -fno-strict-aliasing" )
        if( NOT ANDROID_COMPILER_IS_CLANG )
            set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -finline-limit=64" )
        endif()
    else()
        # always compile ARMEABI_V6 in arm mode; otherwise there is no difference from ARMEABI
        set( ANDROID_CXX_FLAGS_RELEASE "-marm -fomit-frame-pointer -fstrict-aliasing" )
        set( ANDROID_CXX_FLAGS_DEBUG   "-marm -fno-omit-frame-pointer -fno-strict-aliasing" )
        if( NOT ANDROID_COMPILER_IS_CLANG )
            set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -funswitch-loops -finline-limit=300" )
        endif()
    endif()
elseif( X86 OR X86_64)
    set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -funwind-tables" )
    if( NOT ANDROID_COMPILER_IS_CLANG )
        set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -funswitch-loops -finline-limit=300" )
    else()
        set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -fPIC" )
    endif()
    set( ANDROID_CXX_FLAGS_RELEASE "-fomit-frame-pointer -fstrict-aliasing" )
    set( ANDROID_CXX_FLAGS_DEBUG   "-fno-omit-frame-pointer -fno-strict-aliasing" )
elseif( MIPS OR MIPS64 )
    set( ANDROID_CXX_FLAGS         "${ANDROID_CXX_FLAGS} -fpic -fno-strict-aliasing -finline-functions -ffunction-sections -funwind-tables -fmessage-length=0" )
    set( ANDROID_CXX_FLAGS_RELEASE "-fomit-frame-pointer" )
    set( ANDROID_CXX_FLAGS_DEBUG   "-fno-omit-frame-pointer" )
    if( NOT ANDROID_COMPILER_IS_CLANG )
        set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -fno-inline-functions-called-once -fgcse-after-reload -frerun-cse-after-loop -frename-registers" )
        set( ANDROID_CXX_FLAGS_RELEASE "${ANDROID_CXX_FLAGS_RELEASE} -funswitch-loops -finline-limit=300" )
    endif()
elseif()
    set( ANDROID_CXX_FLAGS_RELEASE "" )
    set( ANDROID_CXX_FLAGS_DEBUG   "" )
endif()

set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -fsigned-char" ) # good/necessary when porting desktop libraries

if( NOT X86 AND NOT ANDROID_COMPILER_IS_CLANG )
    set( ANDROID_CXX_FLAGS "-Wno-psabi ${ANDROID_CXX_FLAGS}" )
endif()

if( NOT ANDROID_COMPILER_VERSION VERSION_LESS "4.6" )
    set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -no-canonical-prefixes" ) # see https://android-review.googlesource.com/#/c/47564/
endif()

########################################
# ABI-specific flags
if( ARMEABI_V7A )
    set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -march=armv7-a -mfloat-abi=softfp" )
    if( NEON )
        set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -mfpu=neon" )
    elseif( VFPV3 )
        set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -mfpu=vfpv3" )
    else()
        set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -mfpu=vfpv3-d16" )
    endif()
elseif( ARMEABI_V6 )
    set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -march=armv6 -mfloat-abi=softfp -mfpu=vfp" ) # vfp == vfpv2
elseif( ARMEABI )
    set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -march=armv5te -mtune=xscale -msoft-float" )
elseif( ARM64_V8A )
    set( ANDROID_CXX_FLAGS "${ANDROID_CXX_FLAGS} -march=armv8-a" )
endif()

if( ANDROID_STL MATCHES "gnustl" AND (EXISTS "${LIB_STL}" OR EXISTS "${LIB_SUPCXX}") )
    set( CMAKE_CXX_CREATE_SHARED_LIBRARY "<CMAKE_C_COMPILER> <CMAKE_SHARED_LIBRARY_CXX_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <CMAKE_SHARED_LIBRARY_SONAME_CXX_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>" )
    set( CMAKE_CXX_CREATE_SHARED_MODULE  "<CMAKE_C_COMPILER> <CMAKE_SHARED_LIBRARY_CXX_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <CMAKE_SHARED_LIBRARY_SONAME_CXX_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>" )
    set( CMAKE_CXX_LINK_EXECUTABLE       "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>" )
else()
    set( CMAKE_CXX_CREATE_SHARED_LIBRARY "<CMAKE_CXX_COMPILER> <CMAKE_SHARED_LIBRARY_CXX_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <CMAKE_SHARED_LIBRARY_SONAME_CXX_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>" )
    set( CMAKE_CXX_CREATE_SHARED_MODULE  "<CMAKE_CXX_COMPILER> <CMAKE_SHARED_LIBRARY_CXX_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <CMAKE_SHARED_LIBRARY_SONAME_CXX_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>" )
    set( CMAKE_CXX_LINK_EXECUTABLE       "<CMAKE_CXX_COMPILER> <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>" )
endif()

########################################
# STL
if( EXISTS "${LIB_STL}" OR EXISTS "${LIB_SUPCXX}" )
    if( EXISTS "${LIB_STL}" )
        set( CMAKE_CXX_CREATE_SHARED_LIBRARY "${CMAKE_CXX_CREATE_SHARED_LIBRARY} \"${LIB_STL}\"" )
        set( CMAKE_CXX_CREATE_SHARED_MODULE  "${CMAKE_CXX_CREATE_SHARED_MODULE} \"${LIB_STL}\"" )
        set( CMAKE_CXX_LINK_EXECUTABLE       "${CMAKE_CXX_LINK_EXECUTABLE} \"${LIB_STL}\"" )
    endif()
    if( EXISTS "${LIB_SUPCXX}" )
        set( CMAKE_CXX_CREATE_SHARED_LIBRARY "${CMAKE_CXX_CREATE_SHARED_LIBRARY} \"${LIB_SUPCXX}\"" )
        set( CMAKE_CXX_CREATE_SHARED_MODULE  "${CMAKE_CXX_CREATE_SHARED_MODULE} \"${LIB_SUPCXX}\"" )
        set( CMAKE_CXX_LINK_EXECUTABLE       "${CMAKE_CXX_LINK_EXECUTABLE} \"${LIB_SUPCXX}\"" )
        # C objects:
        set( CMAKE_C_CREATE_SHARED_LIBRARY "<CMAKE_C_COMPILER> <CMAKE_SHARED_LIBRARY_C_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS> <CMAKE_SHARED_LIBRARY_SONAME_C_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>" )
        set( CMAKE_C_CREATE_SHARED_MODULE  "<CMAKE_C_COMPILER> <CMAKE_SHARED_LIBRARY_C_FLAGS> <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS> <CMAKE_SHARED_LIBRARY_SONAME_C_FLAG><TARGET_SONAME> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>" )
        set( CMAKE_C_LINK_EXECUTABLE       "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>" )
        set( CMAKE_C_CREATE_SHARED_LIBRARY "${CMAKE_C_CREATE_SHARED_LIBRARY} \"${LIB_SUPCXX}\"" )
        set( CMAKE_C_CREATE_SHARED_MODULE  "${CMAKE_C_CREATE_SHARED_MODULE} \"${LIB_SUPCXX}\"" )
        set( CMAKE_C_LINK_EXECUTABLE       "${CMAKE_C_LINK_EXECUTABLE} \"${LIB_SUPCXX}\"" )
    endif()
    if( ANDROID_STL MATCHES "gnustl" )
        if( NOT EXISTS "${ANDROID_LIBM_PATH}" )
            set( ANDROID_LIBM_PATH -lm )
        endif()
        set( CMAKE_CXX_CREATE_SHARED_LIBRARY "${CMAKE_CXX_CREATE_SHARED_LIBRARY} ${ANDROID_LIBM_PATH}" )
        set( CMAKE_CXX_CREATE_SHARED_MODULE  "${CMAKE_CXX_CREATE_SHARED_MODULE} ${ANDROID_LIBM_PATH}" )
        set( CMAKE_CXX_LINK_EXECUTABLE       "${CMAKE_CXX_LINK_EXECUTABLE} ${ANDROID_LIBM_PATH}" )
    endif()
endif()

########################################
# variables controlling optional build flags
if (ANDROID_NDK_RELEASE STRLESS "r7")
    # libGLESv2.so in NDK's prior to r7 refers to missing external symbols.
    # So this flag option is required for all projects using OpenGL from native.
    initVariable( ANDROID_SO_UNDEFINED                      VALUES ON )
else()
    initVariable( ANDROID_SO_UNDEFINED                      VALUES OFF )
endif()
initVariable( ANDROID_NO_UNDEFINED OBSOLETE_NO_UNDEFINED VALUES ON )
initVariable( ANDROID_FUNCTION_LEVEL_LINKING             VALUES ON )
initVariable( ANDROID_GOLD_LINKER                        VALUES ON )
initVariable( ANDROID_NOEXECSTACK                        VALUES ON )
initVariable( ANDROID_RELRO                              VALUES ON )

set( ANDROID_NO_UNDEFINED           ${ANDROID_NO_UNDEFINED}           CACHE BOOL "Show all undefined symbols as linker errors" )
set( ANDROID_SO_UNDEFINED           ${ANDROID_SO_UNDEFINED}           CACHE BOOL "Allows or disallows undefined symbols in shared libraries" )
set( ANDROID_FUNCTION_LEVEL_LINKING ${ANDROID_FUNCTION_LEVEL_LINKING} CACHE BOOL "Allows or disallows undefined symbols in shared libraries" )
set( ANDROID_GOLD_LINKER            ${ANDROID_GOLD_LINKER}            CACHE BOOL "Enables gold linker (only avaialble for NDK r8b for ARM and x86 architectures on linux-86 and darwin-x86 hosts)" )
set( ANDROID_NOEXECSTACK            ${ANDROID_NOEXECSTACK}            CACHE BOOL "Allows or disallows undefined symbols in shared libraries" )
set( ANDROID_RELRO                  ${ANDROID_RELRO}                  CACHE BOOL "Enables RELRO - a memory corruption mitigation technique" )
mark_as_advanced( ANDROID_NO_UNDEFINED ANDROID_SO_UNDEFINED ANDROID_FUNCTION_LEVEL_LINKING ANDROID_GOLD_LINKER ANDROID_NOEXECSTACK ANDROID_RELRO )

########################################
# linker flags
set( ANDROID_LINKER_FLAGS "" )

if( ARMEABI_V7A )
 # this is *required* to use the following linker flags that routes around
 # a CPU bug in some Cortex-A8 implementations:
 set( ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,--fix-cortex-a8" )
endif()

if( ANDROID_NO_UNDEFINED )
 if( MIPS )
  # there is some sysroot-related problem in mips linker...
  if( NOT ANDROID_SYSROOT MATCHES "[ ;\"]" )
   set( ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,--no-undefined -Wl,-rpath-link,${ANDROID_SYSROOT}/usr/lib" )
  endif()
 else()
  set( ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,--no-undefined" )
 endif()
endif()

if( ANDROID_SO_UNDEFINED )
 set( ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,-allow-shlib-undefined" )
endif()

if( ANDROID_FUNCTION_LEVEL_LINKING )
 set( ANDROID_CXX_FLAGS    "${ANDROID_CXX_FLAGS} -fdata-sections -ffunction-sections" )
 set( ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,--gc-sections" )
endif()

if( ANDROID_COMPILER_VERSION VERSION_EQUAL "4.6" )
 if( ANDROID_GOLD_LINKER AND (CMAKE_HOST_UNIX OR ANDROID_NDK_RELEASE STRGREATER "r8b") AND (ARMEABI OR ARMEABI_V7A OR X86) )
  set( ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -fuse-ld=gold" )
 elseif( ANDROID_NDK_RELEASE STRGREATER "r8b")
  set( ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -fuse-ld=bfd" )
 elseif( ANDROID_NDK_RELEASE STREQUAL "r8b" AND ARMEABI AND NOT CMAKE_IN_TRY_COMPILE )
  message( WARNING "The default bfd linker from arm GCC 4.6 toolchain can fail with 'unresolvable R_ARM_THM_CALL relocation' error message. See https://code.google.com/p/android/issues/detail?id=35342
  On Linux and OS X host platform you can workaround this problem using gold linker (default).
  Rerun cmake with -DANDROID_GOLD_LINKER=ON option in case of problems.
" )
 endif()
endif() # version 4.6

if( ANDROID_NOEXECSTACK )
 if( ANDROID_COMPILER_IS_CLANG )
  set( ANDROID_CXX_FLAGS    "${ANDROID_CXX_FLAGS} -Xclang -mnoexecstack" )
 else()
  set( ANDROID_CXX_FLAGS    "${ANDROID_CXX_FLAGS} -Wa,--noexecstack" )
 endif()
 set( ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,-z,noexecstack" )
endif()

if( ANDROID_RELRO )
 set( ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,-z,relro -Wl,-z,now" )
endif()

if( ANDROID_COMPILER_IS_CLANG )
 set( ANDROID_CXX_FLAGS "-Qunused-arguments ${ANDROID_CXX_FLAGS}" )
 if( ARMEABI_V7A AND NOT ANDROID_FORCE_ARM_BUILD )
  set( ANDROID_CXX_FLAGS_RELEASE "-target thumbv7-none-linux-androideabi ${ANDROID_CXX_FLAGS_RELEASE}" )
  set( ANDROID_CXX_FLAGS_DEBUG   "-target ${ANDROID_LLVM_TRIPLE} ${ANDROID_CXX_FLAGS_DEBUG}" )
 else()
  set( ANDROID_CXX_FLAGS "-target ${ANDROID_LLVM_TRIPLE} ${ANDROID_CXX_FLAGS}" )
 endif()
 if( BUILD_WITH_ANDROID_NDK )
  set( ANDROID_CXX_FLAGS "-gcc-toolchain ${ANDROID_TOOLCHAIN_ROOT} ${ANDROID_CXX_FLAGS}" )
 endif()
endif()

########################################
# cache flags
set( CMAKE_CXX_FLAGS           ""                        CACHE STRING "c++ flags" )
set( CMAKE_C_FLAGS             ""                        CACHE STRING "c flags" )
set( CMAKE_CXX_FLAGS_RELEASE   "-O3 -DNDEBUG"            CACHE STRING "c++ Release flags" )
set( CMAKE_C_FLAGS_RELEASE     "-O3 -DNDEBUG"            CACHE STRING "c Release flags" )
set( CMAKE_CXX_FLAGS_DEBUG     "-O0 -g -DDEBUG -D_DEBUG" CACHE STRING "c++ Debug flags" )
set( CMAKE_C_FLAGS_DEBUG       "-O0 -g -DDEBUG -D_DEBUG" CACHE STRING "c Debug flags" )
set( CMAKE_SHARED_LINKER_FLAGS ""                        CACHE STRING "shared linker flags" )
set( CMAKE_MODULE_LINKER_FLAGS ""                        CACHE STRING "module linker flags" )
set( CMAKE_EXE_LINKER_FLAGS    "-Wl,-z,nocopyreloc"      CACHE STRING "executable linker flags" )

# put flags to cache (for debug purpose only)
set( ANDROID_CXX_FLAGS         "${ANDROID_CXX_FLAGS}"         CACHE INTERNAL "Android specific c/c++ flags" )
set( ANDROID_CXX_FLAGS_RELEASE "${ANDROID_CXX_FLAGS_RELEASE}" CACHE INTERNAL "Android specific c/c++ Release flags" )
set( ANDROID_CXX_FLAGS_DEBUG   "${ANDROID_CXX_FLAGS_DEBUG}"   CACHE INTERNAL "Android specific c/c++ Debug flags" )
set( ANDROID_LINKER_FLAGS      "${ANDROID_LINKER_FLAGS}"      CACHE INTERNAL "Android specific c/c++ linker flags" )

# finish flags
set( CMAKE_CXX_FLAGS           "${ANDROID_CXX_FLAGS} ${CMAKE_CXX_FLAGS}" )
set( CMAKE_C_FLAGS             "${ANDROID_CXX_FLAGS} ${CMAKE_C_FLAGS}" )
set( CMAKE_CXX_FLAGS_RELEASE   "${ANDROID_CXX_FLAGS_RELEASE} ${CMAKE_CXX_FLAGS_RELEASE}" )
set( CMAKE_C_FLAGS_RELEASE     "${ANDROID_CXX_FLAGS_RELEASE} ${CMAKE_C_FLAGS_RELEASE}" )
set( CMAKE_CXX_FLAGS_DEBUG     "${ANDROID_CXX_FLAGS_DEBUG} ${CMAKE_CXX_FLAGS_DEBUG}" )
set( CMAKE_C_FLAGS_DEBUG       "${ANDROID_CXX_FLAGS_DEBUG} ${CMAKE_C_FLAGS_DEBUG}" )
set( CMAKE_SHARED_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS}" )
set( CMAKE_MODULE_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS}" )
set( CMAKE_EXE_LINKER_FLAGS    "${ANDROID_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS}" )

if( MIPS AND BUILD_WITH_ANDROID_NDK AND ANDROID_NDK_RELEASE STREQUAL "r8" )
 set( CMAKE_SHARED_LINKER_FLAGS "-Wl,-T,${ANDROID_NDK_TOOLCHAINS_PATH}/${ANDROID_GCC_TOOLCHAIN_NAME}/mipself.xsc ${CMAKE_SHARED_LINKER_FLAGS}" )
 set( CMAKE_MODULE_LINKER_FLAGS "-Wl,-T,${ANDROID_NDK_TOOLCHAINS_PATH}/${ANDROID_GCC_TOOLCHAIN_NAME}/mipself.xsc ${CMAKE_MODULE_LINKER_FLAGS}" )
 set( CMAKE_EXE_LINKER_FLAGS    "-Wl,-T,${ANDROID_NDK_TOOLCHAINS_PATH}/${ANDROID_GCC_TOOLCHAIN_NAME}/mipself.x ${CMAKE_EXE_LINKER_FLAGS}" )
endif()

########################################
# configure rtti
if( DEFINED ANDROID_RTTI AND ANDROID_STL_FORCE_FEATURES )
 if( ANDROID_RTTI )
  set( CMAKE_CXX_FLAGS "-frtti ${CMAKE_CXX_FLAGS}" )
 else()
  set( CMAKE_CXX_FLAGS "-fno-rtti ${CMAKE_CXX_FLAGS}" )
 endif()
endif()

########################################
# configure exceptios
if( DEFINED ANDROID_EXCEPTIONS AND ANDROID_STL_FORCE_FEATURES )
 if( ANDROID_EXCEPTIONS )
  set( CMAKE_CXX_FLAGS "-fexceptions ${CMAKE_CXX_FLAGS}" )
  set( CMAKE_C_FLAGS "-fexceptions ${CMAKE_C_FLAGS}" )
 else()
  set( CMAKE_CXX_FLAGS "-fno-exceptions ${CMAKE_CXX_FLAGS}" )
  set( CMAKE_C_FLAGS "-fno-exceptions ${CMAKE_C_FLAGS}" )
 endif()
endif()

########################################
# global includes and link directories
include_directories( SYSTEM "${ANDROID_SYSROOT}/usr/include" ${ANDROID_STL_INCLUDE_DIRS} )
get_filename_component(__android_installCURRENT_PATH "${CMAKE_INSTALL_PREFIX}/lib" ABSOLUTE) # avoid CMP0015 policy warning
link_directories( "${__android_installCURRENT_PATH}" )

# detect if need link crtbegin_so.o explicitly
if( NOT DEFINED ANDROID_EXPLICIT_CRT_LINK )
 set( CURRENT_COMMAND "${CMAKE_CXX_CREATE_SHARED_LIBRARY}" )
 string( REPLACE "<CMAKE_CXX_COMPILER>" "${CMAKE_CXX_COMPILER} ${CMAKE_CXX_COMPILER_ARG1}" CURRENT_COMMAND "${CURRENT_COMMAND}" )
 string( REPLACE "<CMAKE_C_COMPILER>"   "${CMAKE_C_COMPILER} ${CMAKE_C_COMPILER_ARG1}"   CURRENT_COMMAND "${CURRENT_COMMAND}" )
 string( REPLACE "<CMAKE_SHARED_LIBRARY_CXX_FLAGS>" "${CMAKE_CXX_FLAGS}" CURRENT_COMMAND "${CURRENT_COMMAND}" )
 string( REPLACE "<LANGUAGE_COMPILE_FLAGS>" "" CURRENT_COMMAND "${CURRENT_COMMAND}" )
 string( REPLACE "<LINK_FLAGS>" "${CMAKE_SHARED_LINKER_FLAGS}" CURRENT_COMMAND "${CURRENT_COMMAND}" )
 string( REPLACE "<CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS>" "-shared" CURRENT_COMMAND "${CURRENT_COMMAND}" )
 string( REPLACE "<CMAKE_SHARED_LIBRARY_SONAME_CXX_FLAG>" "" CURRENT_COMMAND "${CURRENT_COMMAND}" )
 string( REPLACE "<TARGET_SONAME>" "" CURRENT_COMMAND "${CURRENT_COMMAND}" )
 string( REPLACE "<TARGET>" "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/toolchain_crtlink_test.so" CURRENT_COMMAND "${CURRENT_COMMAND}" )
 string( REPLACE "<OBJECTS>" "\"${ANDROID_SYSROOT}/usr/lib/crtbegin_so.o\"" CURRENT_COMMAND "${CURRENT_COMMAND}" )
 string( REPLACE "<LINK_LIBRARIES>" "" CURRENT_COMMAND "${CURRENT_COMMAND}" )
 separate_arguments( CURRENT_COMMAND )
 
 foreach( CURRENT_VAR ANDROID_NDK ANDROID_NDK_TOOLCHAINS_PATH ANDROID_STANDALONE_TOOLCHAIN )
  if( ${CURRENT_VAR} )
   set( TMP_VAR "${${CURRENT_VAR}}" )
   separate_arguments( TMP_VAR )
   string( REPLACE "${TMP_VAR}" "${${CURRENT_VAR}}" CURRENT_COMMAND "${CURRENT_COMMAND}")
  endif()
 endforeach()
 string( REPLACE "'" "" CURRENT_COMMAND "${CURRENT_COMMAND}" )
 string( REPLACE "\"" "" CURRENT_COMMAND "${CURRENT_COMMAND}" )
 execute_process( COMMAND ${CURRENT_COMMAND} RESULT_VARIABLE CURRENT_COMMAND_result OUTPUT_QUIET ERROR_QUIET )
 if( CURRENT_COMMAND_result EQUAL 0 )
  set( ANDROID_EXPLICIT_CRT_LINK ON )
 else()
  set( ANDROID_EXPLICIT_CRT_LINK OFF )
 endif()
endif()

if( ANDROID_EXPLICIT_CRT_LINK )
 set( CMAKE_CXX_CREATE_SHARED_LIBRARY "${CMAKE_CXX_CREATE_SHARED_LIBRARY} \"${ANDROID_SYSROOT}/usr/lib/crtbegin_so.o\"" )
 set( CMAKE_CXX_CREATE_SHARED_MODULE  "${CMAKE_CXX_CREATE_SHARED_MODULE} \"${ANDROID_SYSROOT}/usr/lib/crtbegin_so.o\"" )
endif()

########################################
# setup output directories
set( CMAKE_INSTALL_PREFIX CACHE PATH "path for installing" )

if(NOT CMAKE_IN_TRY_COMPILE)
 if( EXISTS "${CMAKE_SOURCE_DIR}/jni/CMakeLists.txt" )
  set( EXECUTABLE_OUTPUT_PATH "${CMAKE_INSTALL_PREFIX}/bin/${ANDROID_NDK_ABI_NAME}" )
 else()
  set( EXECUTABLE_OUTPUT_PATH "${CMAKE_INSTALL_PREFIX}/bin" )
 endif()
 set( LIBRARY_OUTPUT_PATH "${CMAKE_INSTALL_PREFIX}/lib" )
endif()

########################################
# copy shaed stl library to build directory
if( NOT CMAKE_IN_TRY_COMPILE AND LIB_STL MATCHES "[.]so$" )
 get_filename_component( LIB_STL_NAME "${LIB_STL}" NAME )
 execute_process( COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${LIB_STL}" "${LIBRARY_OUTPUT_PATH}/${LIB_STL_NAME}" RESULT_VARIABLE FILE_COPY_PROCESS )
 if( NOT FILE_COPY_PROCESS EQUAL 0 OR NOT EXISTS "${LIBRARY_OUTPUT_PATH}/${LIB_STL_NAME}")
  message( SEND_ERROR "Failed copying of ${LIB_STL} to the ${LIBRARY_OUTPUT_PATH}/${LIB_STL_NAME}" )
 endif()
 unset( FILE_COPY_PROCESS )
 unset( LIB_STL_NAME )
endif()


# set these global flags for cmake client scripts to change behavior
set( ANDROID True )
set( BUILD_ANDROID True )

# where is the target environment
set( CMAKE_FIND_ROOT_PATH "${ANDROID_TOOLCHAIN_ROOT}/bin" "${ANDROID_TOOLCHAIN_ROOT}/${ANDROID_TOOLCHAIN_MACHINE_NAME}" "${ANDROID_SYSROOT}" "${CMAKE_INSTALL_PREFIX}" "${CMAKE_INSTALL_PREFIX}/share") 

# only search for libraries and includes in the ndk toolchain
set( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
set( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )

########################################
# export toolchain settings for the try_compile() command
if( NOT PROJECT_NAME STREQUAL "CMAKE_TRY_COMPILE" )
 set( CURRENT_TOOLCHAIN_config "")
 foreach( CURRENT_VAR NDK_CCACHE  CMAKE_INSTALL_PREFIX  ANDROID_FORBID_SYGWIN  ANDROID_SET_OBSOLETE_VARIABLES
                ANDROID_NDK_HOST_X64
                ANDROID_NDK
                ANDROID_NDK_LAYOUT
                ANDROID_STANDALONE_TOOLCHAIN
                ANDROID_TOOLCHAIN_NAME
                ANDROID_ABI
                ANDROID_NATIVE_API_LEVEL
                ANDROID_STL
                ANDROID_STL_FORCE_FEATURES
                ANDROID_FORCE_ARM_BUILD
                ANDROID_NO_UNDEFINED
                ANDROID_SO_UNDEFINED
                ANDROID_FUNCTION_LEVEL_LINKING
                ANDROID_GOLD_LINKER
                ANDROID_NOEXECSTACK
                ANDROID_RELRO
                ANDROID_LIBM_PATH
                ANDROID_EXPLICIT_CRT_LINK
                )
  if( DEFINED ${CURRENT_VAR} )
   if( "${CURRENT_VAR}" MATCHES " ")
    set( CURRENT_TOOLCHAIN_config "${CURRENT_TOOLCHAIN_config}set( ${CURRENT_VAR} \"${${CURRENT_VAR}}\" CACHE INTERNAL \"\" )\n" )
   else()
    set( CURRENT_TOOLCHAIN_config "${CURRENT_TOOLCHAIN_config}set( ${CURRENT_VAR} ${${CURRENT_VAR}} CACHE INTERNAL \"\" )\n" )
   endif()
  endif()
 endforeach()
 file( WRITE "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/android.toolchain.config.cmake" "${CURRENT_TOOLCHAIN_config}" )
 unset( CURRENT_TOOLCHAIN_config )
endif()

########################################
# force cmake to produce / instead of \ in build commands for Ninja generator
if( CMAKE_GENERATOR MATCHES "Ninja" AND CMAKE_HOST_WIN32 )
 # it is a bad hack after all
 # CMake generates Ninja makefiles with UNIX paths only if it thinks that we are going to build with MinGW
 set( CMAKE_COMPILER_IS_MINGW TRUE ) # tell CMake that we are MinGW
 set( CMAKE_CROSSCOMPILING TRUE )    # stop recursion
 enable_language( C )
 enable_language( CXX )
 # unset( CMAKE_COMPILER_IS_MINGW ) # can't unset because CMake does not convert back-slashes in response files without it
 unset( MINGW )
endif()

########################################
# set some obsolete variables for backward compatibility
set( ANDROID_SET_OBSOLETE_VARIABLES ON CACHE BOOL "Define obsolete Andrid-specific cmake variables" )
mark_as_advanced( ANDROID_SET_OBSOLETE_VARIABLES )
if( ANDROID_SET_OBSOLETE_VARIABLES )
 set( ANDROID_API_LEVEL ${ANDROID_NATIVE_API_LEVEL} )
 set( ARM_TARGET "${ANDROID_ABI}" )
 set( ARMEABI_NDK_NAME "${ANDROID_NDK_ABI_NAME}" )
endif()

########################################