# CMake 3.20+ has built-in FindVulkan module
find_package(Vulkan REQUIRED)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    add_compile_definitions(VK_USE_PLATFORM_WIN32_KHR WIN32_LEAN_AND_MEAN)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Android")
    add_compile_definitions(VK_USE_PLATFORM_ANDROID_KHR)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    add_compile_definitions(VK_USE_PLATFORM_MACOS_MVK)
elseif(UNIX)
    add_compile_definitions(VK_USE_PLATFORM_XCB_KHR)
    set(RENDER_LIBRARY xcb)
else()
    message(FATAL_ERROR "Unsupported Vulkan Platform!")
endif()

# CMake 3.20+ always provides Vulkan::Vulkan imported target
message(STATUS "Vulkan found: using Vulkan::Vulkan imported target")
