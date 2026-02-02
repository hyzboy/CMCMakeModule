find_package(glm CONFIG REQUIRED)

add_compile_definitions(GLM_FORCE_RADIANS)
add_compile_definitions(GLM_FORCE_DEPTH_ZERO_TO_ONE)
add_compile_definitions(GLM_ENABLE_EXPERIMENTAL)
add_compile_definitions(GLM_FORCE_DEFAULT_ALIGNED_GENTYPES)

if(WIN32)
    add_compile_definitions(GLM_FORCE_AVX2)

    set(HGL_MATH_LIB glm::glm)
else()
    set(HGL_MATH_LIB GLM)
endif()
