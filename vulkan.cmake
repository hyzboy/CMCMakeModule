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

# Provide Vulkan headers to consumers that rely on global include dirs
if(Vulkan_INCLUDE_DIRS)
    include_directories(SYSTEM ${Vulkan_INCLUDE_DIRS})
    list(APPEND CMAKE_INCLUDE_PATH ${Vulkan_INCLUDE_DIRS})
    message(STATUS "Vulkan include directories: ${Vulkan_INCLUDE_DIRS}")
endif()

# Surface Vulkan library directories so legacy link_directories users work
if(Vulkan_LIBRARIES)
    set(_VULKAN_LIBRARY_DIRS "")
    foreach(_vk_entry IN LISTS Vulkan_LIBRARIES)
        set(_vk_library_path "")
        if(TARGET ${_vk_entry})
            get_target_property(_vk_is_imported ${_vk_entry} IMPORTED)
            if(_vk_is_imported)
                get_target_property(_vk_import_lib ${_vk_entry} IMPORTED_IMPLIB)
                if(_vk_import_lib)
                    set(_vk_library_path ${_vk_import_lib})
                else()
                    get_target_property(_vk_library_path ${_vk_entry} IMPORTED_LOCATION)
                endif()
            endif()
        else()
            set(_vk_library_path ${_vk_entry})
        endif()

        if(_vk_library_path AND EXISTS "${_vk_library_path}")
            get_filename_component(_vk_library_dir "${_vk_library_path}" DIRECTORY)
            list(APPEND _VULKAN_LIBRARY_DIRS "${_vk_library_dir}")
        endif()
    endforeach()

    list(REMOVE_DUPLICATES _VULKAN_LIBRARY_DIRS)
    if(_VULKAN_LIBRARY_DIRS)
        link_directories(${_VULKAN_LIBRARY_DIRS})
        list(APPEND CMAKE_LIBRARY_PATH ${_VULKAN_LIBRARY_DIRS})
        message(STATUS "Vulkan library directories: ${_VULKAN_LIBRARY_DIRS}")
    endif()
endif()

# Optionally add Vulkan SDK include and library paths from VULKAN_SDK
# This helps projects that rely on global include/link directories.
if(DEFINED ENV{VULKAN_SDK} AND NOT "$ENV{VULKAN_SDK}" STREQUAL "")
    set(_VULKAN_SDK_ROOT "$ENV{VULKAN_SDK}")

    if(WIN32)
        # Include dir is fixed; lib dir depends on arch
        set(VULKAN_SDK_INCLUDE_DIR "${_VULKAN_SDK_ROOT}/Include" CACHE PATH "Vulkan SDK include directory")
        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
            set(VULKAN_SDK_LIBRARY_DIR "${_VULKAN_SDK_ROOT}/Lib" CACHE PATH "Vulkan SDK library directory")
        else()
            set(VULKAN_SDK_LIBRARY_DIR "${_VULKAN_SDK_ROOT}/Lib32" CACHE PATH "Vulkan SDK library directory")
        endif()
    else()
        # Common Unix-like layouts
        set(VULKAN_SDK_INCLUDE_DIR "${_VULKAN_SDK_ROOT}/include" CACHE PATH "Vulkan SDK include directory")
        if(EXISTS "${_VULKAN_SDK_ROOT}/lib")
            set(VULKAN_SDK_LIBRARY_DIR "${_VULKAN_SDK_ROOT}/lib" CACHE PATH "Vulkan SDK library directory")
        elseif(EXISTS "${_VULKAN_SDK_ROOT}/lib64")
            set(VULKAN_SDK_LIBRARY_DIR "${_VULKAN_SDK_ROOT}/lib64" CACHE PATH "Vulkan SDK library directory")
        endif()
    endif()

    if(EXISTS "${VULKAN_SDK_INCLUDE_DIR}")
        include_directories(SYSTEM ${VULKAN_SDK_INCLUDE_DIR})
        list(APPEND CMAKE_INCLUDE_PATH "${VULKAN_SDK_INCLUDE_DIR}")
        message(STATUS "Vulkan SDK Include: ${VULKAN_SDK_INCLUDE_DIR}")
    endif()

    if(DEFINED VULKAN_SDK_LIBRARY_DIR AND EXISTS "${VULKAN_SDK_LIBRARY_DIR}")
        link_directories(${VULKAN_SDK_LIBRARY_DIR})
        list(APPEND CMAKE_LIBRARY_PATH "${VULKAN_SDK_LIBRARY_DIR}")
        message(STATUS "Vulkan SDK Library: ${VULKAN_SDK_LIBRARY_DIR}")
    endif()
endif()
