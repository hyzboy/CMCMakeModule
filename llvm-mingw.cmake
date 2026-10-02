# llvm-mingw 工具链（Qt6 / CMQT 构建用，Windows）
# 与 Qt 安装包附带的 llvm-mingw 配套：Ninja + clang++（MinGW ABI）。
# 用法：cmake -S . -B build/qt -G Ninja -DCMAKE_TOOLCHAIN_FILE=CMCMakeModule/llvm-mingw.cmake ...
# 覆盖编译器根目录：-DQT_LLVM_MINGW_ROOT=D:/path/to/llvm-mingwXXXX_64

if(NOT DEFINED QT_LLVM_MINGW_ROOT)
    set(QT_LLVM_MINGW_ROOT "D:/Qt/Tools/llvm-mingw1706_64")
endif()

set(CMAKE_SYSTEM_NAME Windows)

set(CMAKE_C_COMPILER   "${QT_LLVM_MINGW_ROOT}/bin/clang.exe")
set(CMAKE_CXX_COMPILER "${QT_LLVM_MINGW_ROOT}/bin/clang++.exe")
set(CMAKE_RC_COMPILER  "${QT_LLVM_MINGW_ROOT}/bin/llvm-windres.exe")

set(CMAKE_C_COMPILER_TARGET   x86_64-w64-mingw32)
set(CMAKE_CXX_COMPILER_TARGET x86_64-w64-mingw32)

# llvm-mingw 17.06 的默认 C++ 标准库为 libc++（头在 <root>/include/c++/v1）。
# 需显式 -stdlib=libc++：clang 17 默认即 libc++，但借用的 clang-scan-deps 22
# 在模拟依赖解析时只有看到该参数才会搜索 libc++ 头（否则报 type_traits not found）。
set(CMAKE_CXX_FLAGS_INIT "-stdlib=libc++")

# llvm-mingw 1706 未附带 clang-scan-deps 可执行文件，CMake 4.x 对 clang 的
# Ninja 依赖扫描（.ddi）硬编码走 clang-scan-deps；借用同安装的 2217 版本扫描器。
# 需 FORCE：CMake 检测 clang 后会把该变量覆盖为 -NOTFOUND。
set(CMAKE_CXX_COMPILER_CLANG_SCAN_DEPS
    "D:/Qt/Tools/llvm-mingw2217_64/bin/clang-scan-deps.exe" CACHE FILEPATH "" FORCE)
set(CMAKE_C_COMPILER_CLANG_SCAN_DEPS
    "D:/Qt/Tools/llvm-mingw2217_64/bin/clang-scan-deps.exe" CACHE FILEPATH "" FORCE)
set(CMAKE_ASM_COMPILER_CLANG_SCAN_DEPS
    "D:/Qt/Tools/llvm-mingw2217_64/bin/clang-scan-deps.exe" CACHE FILEPATH "" FORCE)

# llvm-mingw 1706 未附带 clang-scan-deps 可执行文件，CMake 4.x 默认的
# C++20 module 扫描（.ddi）会失败；ULRE/CMQT 不使用 modules，直接关闭。
set(CMAKE_CXX_SCAN_FOR_MODULES OFF CACHE BOOL "Disable C++20 module dependency scanning (llvm-mingw has no clang-scan-deps)" FORCE)
