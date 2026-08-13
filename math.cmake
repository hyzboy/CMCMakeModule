# 优先使用 Vulkan SDK 自带的 GLM（header-only），避免依赖 vcpkg 安装 glm
set(HGL_GLM_SDK_INCLUDE "")

if(WIN32 AND DEFINED ENV{VULKAN_SDK} AND EXISTS "$ENV{VULKAN_SDK}/Include/glm/glm.hpp")
    set(HGL_GLM_SDK_INCLUDE "$ENV{VULKAN_SDK}/Include")
endif()

add_compile_definitions(GLM_FORCE_RADIANS)
add_compile_definitions(GLM_FORCE_DEPTH_ZERO_TO_ONE)
add_compile_definitions(GLM_ENABLE_EXPERIMENTAL)
add_compile_definitions(GLM_FORCE_DEFAULT_ALIGNED_GENTYPES)

if(WIN32)
    add_compile_definitions(GLM_FORCE_AVX2)

    if(HGL_GLM_SDK_INCLUDE)
        # 使用 Vulkan SDK 自带的 GLM 头文件（glm::glm 为 header-only interface target）
        add_library(glm::glm INTERFACE IMPORTED)
        set_target_properties(glm::glm PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${HGL_GLM_SDK_INCLUDE}")

        set(HGL_MATH_LIB glm::glm)
    else()
        find_package(glm CONFIG REQUIRED)
        set(HGL_MATH_LIB glm::glm)
    endif()
else()
    find_package(glm CONFIG REQUIRED)
    set(HGL_MATH_LIB GLM)
endif()
