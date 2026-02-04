# Option: use static C runtime (define once, apply per-toolchain)
option(USE_STATIC_CRT "Use static C runtime (MSVC: /MT, others: -static-libgcc -static-libstdc++)" ON)

# Sanitizers (cross-toolchain toggles)
option(ENABLE_ASAN "Enable AddressSanitizer on supported compilers" OFF)
option(ENABLE_UBSAN "Enable UndefinedBehaviorSanitizer on supported compilers" OFF)

# Global language standards (prefer CMake variables over hardcoded -std or /std flags)
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# CMake 3.28+ fully supports CMP0091, enable it unconditionally
cmake_policy(SET CMP0091 NEW)

if(MSVC)
    # Display runtime library info
    if(CMAKE_MSVC_RUNTIME_LIBRARY AND CMAKE_MSVC_RUNTIME_LIBRARY MATCHES "MultiThreaded[^D]")
        # Using static runtime (MT/MTd)
        message(STATUS "Using static runtime: MT/MTd")
    else()
        # Using DLL runtime (MD/MDd) - default
        message(STATUS "Using DLL runtime: MD/MDd")
    endif()
endif()

# C++20 Module support (CMake 3.28+ required)
message(STATUS "CMake version ${CMAKE_VERSION} supports C++20 modules")

# Enable experimental C++20 module support
set(CMAKE_EXPERIMENTAL_CXX_MODULE_CMAKE_API "2182bf5c-ef0d-489a-91da-49dbc3090d2a")
set(CMAKE_EXPERIMENTAL_CXX_MODULE_DYNDEP ON)

# Configure module output directories
set(CMAKE_CXX_MODULE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/modules")

# Enable scanning for module dependencies
if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    # MSVC-specific module settings
    set(CMAKE_CXX_SCAN_FOR_MODULES ON)
    message(STATUS "C++20 modules enabled for MSVC")
elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    # Clang-specific module settings (requires Clang 16+)
    set(CMAKE_CXX_SCAN_FOR_MODULES ON)
    message(STATUS "C++20 modules enabled for Clang")
elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    # GCC module support (requires GCC 11+ with -fmodules-ts)
    set(CMAKE_CXX_SCAN_FOR_MODULES ON)
    message(STATUS "C++20 modules enabled for GCC")
endif()

if(WIN32)

    if(MSVC)
        set(MSVC_COMMON_FLAGS "/Zc:preprocessor /arch:AVX2 /fp:fast /fp:except- /utf-8")

        # Rely on CMAKE_C_STANDARD/CMAKE_CXX_STANDARD for language mode, only append common flags here
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${MSVC_COMMON_FLAGS}")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${MSVC_COMMON_FLAGS}")

        # MSVC C++20 module specific flags
        # Enable module interface unit compilation
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /interface /ifcOutput ${CMAKE_CXX_MODULE_OUTPUT_DIRECTORY}")

        option(MSVC_USE_fsanitize "USE fsanitize" OFF)
        option(MSVC_USE_SecurityDevlopmentLiftCycle "use Security Development Lifecycle (SDL)" OFF)

        if(MSVC_USE_SecurityDevlopmentLiftCycle)
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /sdl")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /sdl")
        endif()

        if(MSVC_USE_fsanitize OR ENABLE_ASAN)
            set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /fsanitize=address")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /fsanitize=address")
            message(STATUS "MSVC AddressSanitizer enabled")
        endif()

        # Configure MSVC runtime library according to USE_STATIC_CRT
        if(USE_STATIC_CRT)
            message(STATUS "Using static runtime on MSVC toolchain (/MT, /MTd)")
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
        else()
            message(STATUS "Using dynamic runtime on MSVC toolchain (/MD, /MDd)")
            set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
        endif()

        add_compile_definitions(_CRT_SECURE_NO_WARNINGS)

        add_compile_options(/wd4244)    # ->int     精度丢失
        add_compile_options(/wd4305)    # ->float   精度丢失
        add_compile_options(/wd4311)    # template
        add_compile_options(/wd4800)    # ->bool    性能损失
        add_compile_options(/wd4804)    # unsafe compare
        add_compile_options(/wd4805)    # unsafe compare
        add_compile_options(/wd4819)    # ansi->unicode
        add_compile_options(/wd4996)    # sprintf/sscanf unsafe
    endif()

else()
    if(NOT ANDROID)
        if(APPLE)
            set(USE_CLANG       ON)
        else()
            option(USE_CLANG    OFF)
        endif()

        if(USE_CLANG)
            set(CMAKE_C_COMPILER /usr/bin/clang)
            set(CMAKE_CXX_COMPILER /usr/bin/clang++)
        endif()
    endif()
endif()

# Unified GNU/Clang settings (applies to GCC, Clang, AppleClang on all platforms)
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang|AppleClang")
    # C++20 module support for GCC/Clang
    if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        # GCC requires -fmodules-ts flag for module support
        add_compile_options($<$<COMPILE_LANGUAGE:CXX>:-fmodules-ts>)
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        # Clang 16+ has better module support
        # Module flags are handled automatically by CMake 3.28+
    endif()

    # Common ISA/FP
    add_compile_options(-mavx2 -ffast-math)

    # Config-specific optimization and debug info
    if(WIN32)
        add_compile_options($<$<CONFIG:Debug>:-g>)
    else()
        add_compile_options($<$<CONFIG:Debug>:-ggdb3>)
    endif()
    add_compile_options($<$<CONFIG:Release>:-O3>)

    # MinGW specifics
    if(MINGW)
        add_compile_options($<$<CONFIG:Debug>:-Wall>)
        add_compile_definitions(_WIN32_WINNT=0x0601)
    endif()

    # Sanitizers for GCC/Clang
    if(ENABLE_ASAN)
        add_compile_options(-fsanitize=address -fno-omit-frame-pointer)
        add_link_options(-fsanitize=address)
        if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            message(STATUS "Clang AddressSanitizer enabled")
        else()
            message(STATUS "GCC AddressSanitizer enabled")
        endif()
    endif()
    if(ENABLE_UBSAN)
        add_compile_options(-fsanitize=undefined -fno-sanitize-recover=undefined)
        add_link_options(-fsanitize=undefined)
        if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            message(STATUS "Clang UndefinedBehaviorSanitizer enabled")
        else()
            message(STATUS "GCC UndefinedBehaviorSanitizer enabled")
        endif()
    endif()

    # Static libgcc/libstdc++ when requested - differentiate between GCC and Clang
    if(USE_STATIC_CRT AND (MINGW OR (NOT WIN32 AND NOT APPLE AND NOT ANDROID)))
        if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            # GCC: static link libgcc and libstdc++
            message(STATUS "Using static libgcc/libstdc++ on GCC toolchain")
            add_link_options(-static-libgcc -static-libstdc++)
        elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
            # Clang on Linux/BSD: may use libstdc++ (GNU) for GCC compatibility
            message(STATUS "Using static runtime on Clang toolchain (Linux/BSD)")
            add_link_options(-static-libgcc)

            # Check if using libc++ or libstdc++
            if(CMAKE_CXX_FLAGS MATCHES "-stdlib=libc\\+\\+")
                # Using libc++, try to link it statically
                add_link_options(-static-libstdc++ -lc++abi)
            else()
                # Using libstdc++ (GNU's C++ stdlib) for compatibility, link it statically
                add_link_options(-static-libstdc++)
            endif()
        endif()
    endif()

    # Apple platforms (macOS/iOS): always use libc++ (mandated by Apple)
    if(APPLE AND USE_STATIC_CRT)
        message(STATUS "Apple platform: using libc++ (system default, static linking discouraged)")
        # Note: On Apple platforms, static linking of system libraries is generally not recommended
        # The system always provides libc++ dynamically; -static flags may cause issues
    endif()

    # Android NDK (r18+): always uses libc++ (LLVM)
    if(ANDROID AND USE_STATIC_CRT)
        message(STATUS "Android NDK: using libc++ (LLVM, NDK r18+ default)")
        # Android NDK uses libc++_static or libc++_shared
        # Set via ANDROID_STL in toolchain file, typically: c++_static or c++_shared
        if(NOT ANDROID_STL)
            set(ANDROID_STL "c++_static")
            message(STATUS "Setting ANDROID_STL=c++_static for static C++ runtime")
        endif()
    endif()
endif()

# Diagnostics
message(STATUS "C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "C++ Compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "C Flags: ${CMAKE_C_FLAGS}")
message(STATUS "C++ Flags: ${CMAKE_CXX_FLAGS}")
