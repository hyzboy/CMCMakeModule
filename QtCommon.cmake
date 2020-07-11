﻿macro(fix_project_version)
    if (NOT PROJECT_VERSION_PATCH)
        set(PROJECT_VERSION_PATCH 0)
    endif()

    if (NOT PROJECT_VERSION_TWEAK)
        set(PROJECT_VERSION_TWEAK 0)
    endif()
endmacro()

macro(add_project_meta FILES_TO_INCLUDE)
    if (NOT RESOURCE_FOLDER)
        set(RESOURCE_FOLDER res)
    endif()

    if (NOT ICON_NAME)
        set(ICON_NAME AppIcon)
    endif()

    if (APPLE)
        set(ICON_FILE GUI/${RESOURCE_FOLDER}/${ICON_NAME}.icns)
    elseif (WIN32)
        set(ICON_FILE GUI/${RESOURCE_FOLDER}/${ICON_NAME}.ico)
    endif()

    # if (WIN32)
    #     configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/windows_metafile.rc.in"
    #       "windows_metafile.rc"
    #     )
    #     set(RES_FILES "windows_metafile.rc")
    #     set(CMAKE_RC_COMPILER_INIT windres)
    #     ENABLE_LANGUAGE(RC)
    #     SET(CMAKE_RC_COMPILE_OBJECT "<CMAKE_RC_COMPILER> <FLAGS> -O coff <DEFINES> -i <SOURCE> -o <OBJECT>")
    # endif()

    if (APPLE)
        set_source_files_properties(${ICON_FILE} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)

        # Identify MacOS bundle
        set(MACOSX_BUNDLE_BUNDLE_NAME ${PROJECT_NAME})
        set(MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION})
        set(MACOSX_BUNDLE_LONG_VERSION_STRING ${PROJECT_VERSION})
        set(MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}")
        set(MACOSX_BUNDLE_COPYRIGHT ${COPYRIGHT})
        set(MACOSX_BUNDLE_GUI_IDENTIFIER ${IDENTIFIER})
        set(MACOSX_BUNDLE_ICON_FILE ${ICON_NAME})
    endif()

    if (APPLE)
        set(${FILES_TO_INCLUDE} ${ICON_FILE})
    elseif (WIN32)
        set(${FILES_TO_INCLUDE} ${RES_FILES})
    endif()
endmacro()

macro(init_os_bundle)
    if (APPLE)
        set(OS_BUNDLE MACOSX_BUNDLE)
    elseif (WIN32)
        set(OS_BUNDLE WIN32)
    endif()
endmacro()

macro(fix_win_compiler)

endmacro()

macro(init_qt)
    # Let's do the CMake job for us
    set(CMAKE_AUTOMOC ON) # For meta object compiler
    set(CMAKE_AUTORCC ON) # Resource files
    set(CMAKE_AUTOUIC ON) # UI files
endmacro()

init_os_bundle()
init_qt()
fix_win_compiler()

set(QT_MIN_VERSION "5.14.0")
find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS Core Gui Widgets)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
# Set additional project information
set(COMPANY "hyzgame.com")
set(COPYRIGHT "Copyright (c) 1997-2020 hyzgame.com. All rights reserved.")
