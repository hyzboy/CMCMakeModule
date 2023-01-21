macro(add_cm_library module_name project_folder)
    message("Create Module <" ${module_name} "> Project Folder <" ${project_folder} ">" )

    set(SOURCE_FILES "${ARGN}")

    IF(WIN32)
        add_library(${module_name} STATIC ${SOURCE_FILES})
        target_link_libraries(${module_name} PRIVATE ${HGL_MATH_LIB})
    ELSE()
        add_library(${module_name} SHARED ${SOURCE_FILES})
    ENDIF(WIN32)

    set_property(TARGET ${module_name} PROPERTY FOLDER ${project_folder})

endmacro()

macro(add_cm_plugin module_name project_folder)
    message("Create Plug-In <" ${module_name} "> Project Folder <" ${project_folder} ">" )

    set(SOURCE_FILES "${ARGN}")

    add_library(${module_name} SHARED ${SOURCE_FILES})

    set_property(TARGET ${module_name} PROPERTY FOLDER ${project_folder})

endmacro()
