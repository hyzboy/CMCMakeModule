﻿IF(WIN32)

    if(MINGW)
        SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -std=c99 -g -fchar8_t")
        SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -std=c++2a -g -fchar8_t -Wall")

        SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -std=c99 -O2 -fchar8_t")
        SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -std=c++2a -O2 -fchar8_t")

        add_definitions(-D_WIN32_WINNT=0x0601)
    else(MSVC)
        SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MDd")
        SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MDd")

        SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MD")
        SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MD")

        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /std:c++latest")

        add_definitions(-D_CRT_SECURE_NO_WARNINGS)
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
    
    OPTION(USE_CHAR8_T OFF)
    
    IF(USE_CHAR8_T)
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++2a -fchar8_t")
        SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c11 -fchar8_t")
    ELSE()
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
        SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c11")
    ENDIF()

    SET(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -ggdb3")
    SET(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -ggdb3")

    SET(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -Ofast")
    SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -Ofast")
ENDIF()

MESSAGE("C Compiler: " ${CMAKE_C_COMPILER})
MESSAGE("C++ Compiler: " ${CMAKE_CXX_COMPILER})
MESSAGE("C Flag: " ${CMAKE_C_FLAGS})
MESSAGE("C++ Flag: " ${CMAKE_CXX_FLAGS})
