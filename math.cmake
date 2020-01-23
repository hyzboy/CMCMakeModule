macro(use_mgl MGL_PATH)
    IF(WIN32)
        add_compile_options(/arch:AVX2)
    ELSE()
        add_compile_options(-mavx2)
    ENDIF()

    add_definitions(-DMATH_USE_OPENGL)
    add_definitions(-DMATH_RIGHTHANDED_CAMERA)
    add_definitions(-DMATH_AVX)

    include_directories(${MGL_PATH}/src)
    add_subdirectory(${MGL_PATH})
endmacro()
