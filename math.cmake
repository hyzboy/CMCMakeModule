macro(use_glm GLM_PATH)

    include_directories(${GLM_PATH})
    add_subdirectory(${GLM_PATH})

endmacro()
