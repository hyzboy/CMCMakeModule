find_package(glm CONFIG REQUIRED)

add_definitions(-DGLM_FORCE_RADIANS)
add_definitions(-DGLM_FORCE_DEPTH_ZERO_TO_ONE)
add_definitions(-DGLM_ENABLE_EXPERIMENTAL)

if(WIN32)
    add_definitions(-DGLM_FORCE_AVX2)
    
    SET(HGL_MATH_LIB glm::glm)
else()
    SET(HGL_MATH_LIB GLM)
endif()
