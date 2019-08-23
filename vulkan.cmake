include(FindVulkan)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    add_definitions(-DVK_USE_PLATFORM_WIN32_KHR -DWIN32_LEAN_AND_MEAN)

    include_directories(${Vulkan_INCLUDE_DIRS})
elseif(CMAKE_SYSTEM_NAME STREQUAL "Android")
    add_definitions(-DVK_USE_PLATFORM_ANDROID_KHR)
elseif(UNIX)
    add_definitions(-DVK_USE_PLATFORM_XCB_KHR)
    SET(RENDER_LIBRARY xcb)
else()
    message(FATAL_ERROR "Unsupported Vulkan Platform!")
ENDIF()

include_directories(${Vulkan_INCLUDE_DIRS})