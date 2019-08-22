include(compiler)
include(system_bit)
include(version)
include(output_path)

macro(use_cm_module module)
    add_subdirectory(CM${module})
    include(CM${module}/path_config.cmake)
    include_directories(CM${module}/inc)
endmacro()

macro(use_mgl mgl_path)
    add_definitions(-DMATH_USE_OPENGL)
    add_definitions(-DMATH_RIGHTHANDED_CAMERA)
    add_definitions(-DMATH_AVX)
    
    include_directories(${mgl_path}/src)
    add_subdirectory(${mgl_path})
endmacro()