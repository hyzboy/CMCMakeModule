# CM Example Project Macro
# Unified macro for creating example projects across all CM modules
#
# Usage:
#   cm_example_project_base(
#       PROJECT_NAME <name>
#       FOLDER_PATH <folder_path>
#       SOURCES <source_files...>
#       [LIBRARIES <libraries...>]
#       [PRIVATE_LIBRARIES <private_libs...>]
#       [WORKING_DIR <dir>]
#   )

macro(cm_example_project_base)
    set(options "")
    set(oneValueArgs PROJECT_NAME FOLDER_PATH WORKING_DIR)
    set(multiValueArgs SOURCES LIBRARIES PRIVATE_LIBRARIES)
    cmake_parse_arguments(EXAMPLE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Create the executable
    add_executable(${EXAMPLE_PROJECT_NAME} ${EXAMPLE_SOURCES})

    # Link common libraries
    target_link_libraries(${EXAMPLE_PROJECT_NAME} PRIVATE CMCore CMPlatform CMUtil tsl::robin_map)

    # Link additional libraries if specified
    if(EXAMPLE_LIBRARIES)
        target_link_libraries(${EXAMPLE_PROJECT_NAME} PUBLIC ${EXAMPLE_LIBRARIES})
    endif()

    # Link private libraries if specified
    if(EXAMPLE_PRIVATE_LIBRARIES)
        target_link_libraries(${EXAMPLE_PROJECT_NAME} PRIVATE ${EXAMPLE_PRIVATE_LIBRARIES})
    endif()

    # Platform-specific settings
    if(UNIX)
        target_link_libraries(${EXAMPLE_PROJECT_NAME} PRIVATE dl)
    endif()

    if(WIN32)
        target_link_libraries(${EXAMPLE_PROJECT_NAME} PRIVATE ${HGL_MATH_LIB})

        # Set debugger working directory
        if(EXAMPLE_WORKING_DIR)
            set_debugger_directory(${EXAMPLE_PROJECT_NAME} ${EXAMPLE_WORKING_DIR})
        else()
            set_debugger_directory(${EXAMPLE_PROJECT_NAME} ${CMAKE_CURRENT_SOURCE_DIR})
        endif()

        # Add manifest if available
        if(CM_MANIFEST)
            target_sources(${EXAMPLE_PROJECT_NAME} PRIVATE ${CM_MANIFEST})
        endif()

        # Add natvis files for MSVC
        if(MSVC AND CM_NATVIS)
            target_sources(${EXAMPLE_PROJECT_NAME} PRIVATE ${CM_NATVIS})
            source_group("natvis" FILES ${CM_NATVIS})
        endif()
    endif()

    # Set folder property for IDE organization
    if(EXAMPLE_FOLDER_PATH)
        set_property(TARGET ${EXAMPLE_PROJECT_NAME} PROPERTY FOLDER "${EXAMPLE_FOLDER_PATH}")
    endif()
endmacro()

# Simplified wrapper for backward compatibility
# Usage: cm_example_project(sub_folder project_name source_files...)
macro(cm_example_project sub_folder project_name)
    cm_example_project_base(
        PROJECT_NAME ${project_name}
        FOLDER_PATH "CM/Examples/${sub_folder}"
        SOURCES ${ARGN}
    )
endmacro()
