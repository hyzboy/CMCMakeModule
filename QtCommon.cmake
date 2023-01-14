macro(fix_project_version)
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

IF(CM_BUILD_QT)
        SET(CM_QT_MAJOR_VERSION "Auto" CACHE STRING "Choose a version of Qt")
        SET(SUPPORTED_QT_VERSION "Auto" 5 6)
        SET_PROPERTY(CACHE CM_QT_MAJOR_VERSION PROPERTY STRINGS ${SUPPORTED_QT_VERSION})

        IF(CM_QT_MAJOR_VERSION STREQUAL "Auto")
            find_package(Qt6Widgets QUIET)
            if(NOT Qt6Widgets_FOUND)
                find_package(Qt5Widgets QUIET)
                if(NOT Qt5Widgets_FOUND)
                    message(FATAL_ERROR "Could not find a valid Qt installation.")
                else()
                    set(CM_QT_MAJOR_VERSION 5)
                endif()
            else()
                set(CM_QT_MAJOR_VERSION 6)
            endif()
        ENDIF()

        add_definitions("-DHGL_QT=${CM_QT_MAJOR_VERSION}")

        if(CM_QT_MAJOR_VERSION VERSION_EQUAL "6")
            set(QT_MIN_VERSION "6.0.0")

            include_directories(${Qt6Core_INCLUDES})
            add_definitions(${Qt6Core_DEFINITIONS})
        elseif(CM_QT_MAJOR_VERSION VERSION_EQUAL "5")
            set(QT_MIN_VERSION "5.14.0")

            include_directories(${Qt5Core_INCLUDES})
            add_definitions(${Qt5Core_DEFINITIONS})
        else()
            SET(CM_QT_MAJOR_VERSION "0")
        endif()

        init_os_bundle()
        init_qt()
        fix_win_compiler()

        find_package(Qt${CM_QT_MAJOR_VERSION} ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS Core Gui Widgets)

        set(CMAKE_INCLUDE_CURRENT_DIR ON)
        # Set additional project information
        set(COMPANY "hyzgame.com")
        set(COPYRIGHT "Copyright (c) 1997-2022 hyzgame.com. All rights reserved.")

        IF(CM_QT_EXTRA_STYLE)
            add_definitions("-DUSE_EXTRA_QT_STYLE")
            SET(CM_QT_EXTRA_STYLE_RC_FILES  ${CMAKE_CURRENT_SOURCE_DIR}/CMQT/src/style/bb10style/qbb10brightstyle.qrc
                                            ${CMAKE_CURRENT_SOURCE_DIR}/CMQT/src/style/bb10style/qbb10darkstyle.qrc)
        ENDIF()

ENDIF(CM_BUILD_QT)
