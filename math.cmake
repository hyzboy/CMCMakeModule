macro(use_glm GLM_PATH)

    add_definitions(-DGLM_FORCE_RADIANS)
    add_definitions(-DGLM_FORCE_DEPTH_ZERO_TO_ONE)
    add_definitions(-DGLM_ENABLE_EXPERIMENTAL)

    include_directories(${GLM_PATH})

    set(GLM_SOURCE_PATH ${GLM_PATH}/glm)

    file(GLOB GLM_ROOT_SOURCE ${GLM_SOURCE_PATH}/*.cpp)
    file(GLOB GLM_ROOT_INLINE ${GLM_SOURCE_PATH}/*.inl)
    file(GLOB GLM_ROOT_HEADER ${GLM_SOURCE_PATH}/*.hpp)
    file(GLOB GLM_ROOT_TEXT ${GLM_PATH}/*.txt)
    file(GLOB GLM_ROOT_MD ${GLM_PATH}/*.md)
    file(GLOB GLM_ROOT_NAT ${GLM_PATH}/util/glm.natvis)

    file(GLOB_RECURSE GLM_CORE_SOURCE ${GLM_SOURCE_PATH}/detail/*.cpp)
    file(GLOB_RECURSE GLM_CORE_INLINE ${GLM_SOURCE_PATH}/detail/*.inl)
    file(GLOB_RECURSE GLM_CORE_HEADER ${GLM_SOURCE_PATH}/detail/*.hpp)

    file(GLOB_RECURSE GLM_EXT_SOURCE ${GLM_SOURCE_PATH}/ext/*.cpp)
    file(GLOB_RECURSE GLM_EXT_INLINE ${GLM_SOURCE_PATH}/ext/*.inl)
    file(GLOB_RECURSE GLM_EXT_HEADER ${GLM_SOURCE_PATH}/ext/*.hpp)

    file(GLOB_RECURSE GLM_GTC_SOURCE ${GLM_SOURCE_PATH}/gtc/*.cpp)
    file(GLOB_RECURSE GLM_GTC_INLINE ${GLM_SOURCE_PATH}/gtc/*.inl)
    file(GLOB_RECURSE GLM_GTC_HEADER ${GLM_SOURCE_PATH}/gtc/*.hpp)

    file(GLOB_RECURSE GLM_GTX_SOURCE ${GLM_SOURCE_PATH}/gtx/*.cpp)
    file(GLOB_RECURSE GLM_GTX_INLINE ${GLM_SOURCE_PATH}/gtx/*.inl)
    file(GLOB_RECURSE GLM_GTX_HEADER ${GLM_SOURCE_PATH}/gtx/*.hpp)

    file(GLOB_RECURSE GLM_SIMD_SOURCE ${GLM_SOURCE_PATH}/simd/*.cpp)
    file(GLOB_RECURSE GLM_SIMD_INLINE ${GLM_SOURCE_PATH}/simd/*.inl)
    file(GLOB_RECURSE GLM_SIMD_HEADER ${GLM_SOURCE_PATH}/simd/*.h)

    source_group("Text Files" FILES ${GLM_ROOT_TEXT} ${GLM_ROOT_MD})
    source_group("Core Files" FILES ${GLM_CORE_SOURCE})
    source_group("Core Files" FILES ${GLM_CORE_INLINE})
    source_group("Core Files" FILES ${GLM_CORE_HEADER})
    source_group("EXT Files" FILES ${GLM_EXT_SOURCE})
    source_group("EXT Files" FILES ${GLM_EXT_INLINE})
    source_group("EXT Files" FILES ${GLM_EXT_HEADER})
    source_group("GTC Files" FILES ${GLM_GTC_SOURCE})
    source_group("GTC Files" FILES ${GLM_GTC_INLINE})
    source_group("GTC Files" FILES ${GLM_GTC_HEADER})
    source_group("GTX Files" FILES ${GLM_GTX_SOURCE})
    source_group("GTX Files" FILES ${GLM_GTX_INLINE})
    source_group("GTX Files" FILES ${GLM_GTX_HEADER})
    source_group("SIMD Files" FILES ${GLM_SIMD_SOURCE})
    source_group("SIMD Files" FILES ${GLM_SIMD_INLINE})
    source_group("SIMD Files" FILES ${GLM_SIMD_HEADER})

    add_library(GLM STATIC ${GLM_ROOT_TEXT}     ${GLM_ROOT_MD}      ${GLM_ROOT_NAT}
                            ${GLM_ROOT_SOURCE}   ${GLM_ROOT_INLINE}  ${GLM_ROOT_HEADER}
                            ${GLM_CORE_SOURCE}   ${GLM_CORE_INLINE}  ${GLM_CORE_HEADER}
                            ${GLM_EXT_SOURCE}    ${GLM_EXT_INLINE}   ${GLM_EXT_HEADER}
                            ${GLM_GTC_SOURCE}    ${GLM_GTC_INLINE}   ${GLM_GTC_HEADER}
                            ${GLM_GTX_SOURCE}    ${GLM_GTX_INLINE}   ${GLM_GTX_HEADER}
                            ${GLM_SIMD_SOURCE}   ${GLM_SIMD_INLINE}  ${GLM_SIMD_HEADER})

endmacro()
