macro(add_cm_library module_name project_folder include_path)
    message("Create Module <" ${module_name} "> Project Folder <" ${project_folder} ">" )

    set(SOURCE_FILES "${ARGN}")

    if(WIN32)
        add_library(${module_name} STATIC ${SOURCE_FILES})
        target_link_libraries(${module_name} PRIVATE ${HGL_MATH_LIB})
    else()
        add_library(${module_name} SHARED ${SOURCE_FILES})
    endif()

    set_target_properties(${module_name} PROPERTIES FOLDER ${project_folder})

    # Export include directories for consumers of this library
    if(include_path)
        # PRIVATE: for the library's own compilation
        target_include_directories(${module_name} PRIVATE ${include_path})
        # PUBLIC: for consumers of this library
        target_include_directories(${module_name} PUBLIC
            $<BUILD_INTERFACE:${include_path}>
            $<INSTALL_INTERFACE:inc>
        )
    endif()

endmacro()

macro(add_cm_plugin module_name project_folder)
    message("Create Plug-In <" ${module_name} "> Project Folder <" ${project_folder} ">" )

    set(SOURCE_FILES "${ARGN}")

    add_library(${module_name} SHARED ${SOURCE_FILES})

    set_target_properties(${module_name} PROPERTIES FOLDER ${project_folder})

endmacro()
