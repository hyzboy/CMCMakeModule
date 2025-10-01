# Option: use static C runtime (define once, apply per-toolchain)
option(USE_STATIC_CRT "Use static C runtime (MSVC: /MT, others: -static-libgcc -static-libstdc++)" ON)

# Global language standards (prefer CMake variables over hardcoded -std or /std flags)
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

IF(WIN32)

    if(MINGW)
        add_compile_options(-mavx2 -fchar8_t -ffast-math)

        SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -g")
        SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -g -Wall")

        SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O3")
        SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")

        add_definitions(-D_WIN32_WINNT=0x0601)

        # Apply static runtime for MinGW when requested
        if(USE_STATIC_CRT)
            message(STATUS "Using static libgcc/libstdc++ on MinGW toolchain")
            set(CMAKE_EXE_LINKER_FLAGS   "${CMAKE_EXE_LINKER_FLAGS} -static-libgcc -static-libstdc++")
            set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -static-libgcc -static-libstdc++")
            set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -static-libgcc -static-libstdc++")
        endif()
    endif()

    if(MSVC)
        find_package(tsl-robin-map CONFIG REQUIRED)

        # Policy CMP0091 is NEW from top-level, so CMAKE_MSVC_RUNTIME_LIBRARY is honored
        if(POLICY CMP0091)
            cmake_policy(SET CMP0091 NEW)
        endif()

        SET(MSVC_COMMON_FLAGS "/Zc:preprocessor /arch:AVX2 /fp:fast /fp:except-")

        # Rely on CMAKE_C_STANDARD/CMAKE_CXX_STANDARD for language mode, only append common flags here
        SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${MSVC_COMMON_FLAGS}")
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${MSVC_COMMON_FLAGS}")

        OPTION(MSVC_USE_fsanitize "USE fsanitize" OFF)

        OPTION(MSVC_USE_SecurityDevlopmentLiftCycle "use Security Development Lifecycle (SDL)" OFF)

        if(MSVC_USE_SecurityDevlopmentLiftCycle)
            SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /sdl")
            SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /sdl")
        endif()

        if(MSVC_USE_fsanitize)
            SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /fsanitize=address")
            SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /fsanitize=address")
        endif()
        
        # Configure MSVC runtime library according to USE_STATIC_CRT (CMake >= 3.15)
        if(USE_STATIC_CRT)
            message(STATUS "Using static runtime on MSVC toolchain (/MT, /MTd)")
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
        else()
            message(STATUS "Using dynamic runtime on MSVC toolchain (/MD, /MDd)")
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
        endif()

        add_definitions(-D_CRT_SECURE_NO_WARNINGS)

        add_compile_options(/wd4244)    # ->int     精度丢失
        add_compile_options(/wd4305)    # ->float   精度丢失
        add_compile_options(/wd4311)    # template
        add_compile_options(/wd4800)    # ->bool    性能损失
        add_compile_options(/wd4804)    # unsafe compare
        add_compile_options(/wd4805)    # unsafe compare
        add_compile_options(/wd4819)    # ansi->unicode
        add_compile_options(/wd4996)    # sprintf/sscanf unsafe
    endif()

ELSE()
    IF(NOT ANDROID)
        IF(APPLE)
            SET(USE_CLANG       ON)
        ELSE()
            OPTION(USE_CLANG    OFF)
        ENDIF()

        if(USE_CLANG)
            SET(CMAKE_C_COMPILER /usr/bin/clang)
            SET(CMAKE_CXX_COMPILER /usr/bin/clang++)
        endif()
    ENDIF()

    add_compile_options(-mavx2 -fchar8_t -ffast-math)

    # Language standards are controlled by CMAKE_C_STANDARD/CMAKE_CXX_STANDARD above

    SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -ggdb3")
    SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -ggdb3")

    SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O3")
    SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3")

    # Apply static runtime for GCC/Clang on non-Windows (skip Apple/Android)
    if(USE_STATIC_CRT AND NOT APPLE AND NOT ANDROID)
        message(STATUS "Using static libgcc/libstdc++ on GCC/Clang toolchains")
        set(CMAKE_EXE_LINKER_FLAGS   "${CMAKE_EXE_LINKER_FLAGS} -static-libgcc -static-libstdc++")
        set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -static-libgcc -static-libstdc++")
        set(CMAKE_MODULE_LINKER_FLAGS "${CMAKE_MODULE_LINKER_FLAGS} -static-libgcc -static-libstdc++")
    endif()
ENDIF()

MESSAGE("C Compiler: " ${CMAKE_C_COMPILER})
MESSAGE("C++ Compiler: " ${CMAKE_CXX_COMPILER})
MESSAGE("C Flag: " ${CMAKE_C_FLAGS})
MESSAGE("C++ Flag: " ${CMAKE_CXX_FLAGS})
