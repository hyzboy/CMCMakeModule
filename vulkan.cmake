# Use CMake's built-in FindVulkan module (available since CMake 3.7)
# Falls back to custom FindVulkan.cmake for older CMake versions
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.7")
    find_package(Vulkan REQUIRED)
else()
    include(FindVulkan)
endif()

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

# Use modern CMake target-based approach when available
if(TARGET Vulkan::Vulkan)
    # Modern CMake: use imported target directly
    # Users should link with Vulkan::Vulkan instead of ${Vulkan_LIBRARIES}
    message(STATUS "Vulkan found: using Vulkan::Vulkan imported target")
else()
    # Legacy fallback
    include_directories(${Vulkan_INCLUDE_DIRS})
    if(DEFINED Vulkan_LIBRARIES_DIR)
        link_directories(${Vulkan_LIBRARIES_DIR})
    endif()
endif()
