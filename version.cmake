message("Host system: " ${CMAKE_HOST_SYSTEM})
message("Host system name: " ${CMAKE_HOST_SYSTEM_NAME})
message("Host system version: " ${CMAKE_HOST_SYSTEM_VERSION})

message("Compile features: " ${CMAKE_CXX_COMPILE_FEATURES})
message("Compile Flags: " ${CMAKE_C_FLAGS})
message("C++ Compile Flags: " ${CMAKE_CXX_FLAGS})
message("Build type: " ${CMAKE_BUILD_TYPE})

add_compile_definitions(HGL_HOST_SYSTEM="${CMAKE_HOST_SYSTEM}")

add_compile_definitions(CMAKE_VERSION="${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}.${CMAKE_PATCH_VERSION}")

if(MSVC)
add_compile_definitions(HGL_WINDOWS_SDK_VERSION="${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}")

message("VS Platform Name: " ${CMAKE_VS_PLATFORM_NAME})
message("VS Platform toolset: " ${CMAKE_VS_PLATFORM_TOOLSET})

endif()

message("C Compile Features: " ${CMAKE_C_COMPILE_FEATURES})
message("C++ Compile Features: " ${CMAKE_CXX_COMPILE_FEATURES})

# add_compile_definitions(HGL_COMPILE_C_FEATURES="${CMAKE_C_COMPILE_FEATURES}")
# add_compile_definitions(HGL_COMPILE_CXX_FEATURES="${CMAKE_CXX_COMPILE_FEATURES}")


