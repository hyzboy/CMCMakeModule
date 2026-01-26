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

# Note: FindVulkan.cmake already defines Vulkan_INCLUDE_DIR and Vulkan_LIBRARY
# as cache variables, so we don't need to create additional cache variables here.
# If you need to inspect the paths in CMAKE-GUI, use the existing Vulkan_* variables.
