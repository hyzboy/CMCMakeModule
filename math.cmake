macro(use_mgl MGL_PATH)
    add_definitions(-DMATH_USE_OPENGL)
    add_definitions(-DMATH_RIGHTHANDED_CAMERA)
    add_definitions(-DMATH_AVX)

    include_directories(${MGL_PATH}/src)
    add_subdirectory(${MGL_PATH})
endmacro()
