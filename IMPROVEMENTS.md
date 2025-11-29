# CMCMakeModule 改进意见

本文档提供了对 CMCMakeModule 仓库的改进意见，按优先级和复杂度分阶段组织，便于逐步推进。

## 项目技术限定

- **CMake 版本**: >= 3.20
- **C++ 标准**: C++20
- **指令集**: AVX2

---

## 阶段一：代码风格统一（低风险）

### 1.1 CMake 命令大小写规范化

**当前问题：**
- 命令大小写不一致（IF/if, SET/set, ELSE/else, ENDIF/endif 混用）
- 现代 CMake 推荐使用小写命令

**涉及文件：**
- `compiler.cmake`: 多处 IF/ELSE/ENDIF/SET/OPTION 大写
- `system_bit.cmake`: IF/ELSE/ENDIF/SET 大写
- `output_path.cmake`: IF/ELSE/SET 大写
- `QtCommon.cmake`: IF/ENDIF/SET 大写
- `cm_modules.cmake`: IF/ENDIF 大写

**改进建议：**
```cmake
# 旧方式
IF(WIN32)
    SET(OUTPUT_DIR "windows")
ELSE()
    SET(OUTPUT_DIR "linux")
ENDIF()

# 现代 CMake 风格
if(WIN32)
    set(OUTPUT_DIR "windows")
else()
    set(OUTPUT_DIR "linux")
endif()
```

### 1.2 注释语言统一

**当前问题：**
- 中英文注释混用
- 建议统一使用英文注释，便于国际化协作

**涉及文件：**
- `compiler.cmake`: 第27-37行、第119-126行含中文注释

---

## 阶段二：代码简化（基于 CMake 3.20+）

### 2.1 移除过时的版本检查

**当前问题：**
- 存在针对 CMake 3.7、3.15 等老版本的兼容代码
- 项目已限定 CMake >= 3.20，这些检查已无意义

**涉及文件及改进：**

**vulkan.cmake:**
```cmake
# 当前代码（可简化）
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.7")
    find_package(Vulkan REQUIRED)
else()
    include(FindVulkan)
endif()

# 简化为（CMake 3.20+ 必定支持内置 FindVulkan）
find_package(Vulkan REQUIRED)
```

**compiler.cmake:**
```cmake
# 可移除的版本检查（第17行）
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.15")
    # ... CMP0091 相关代码
endif()

# CMake 3.20+ 已完全支持 CMP0091，可直接使用
cmake_policy(SET CMP0091 NEW)
```

### 2.2 删除不再需要的自定义模块

**当前问题：**
- `FindVulkan.cmake` 已被 CMake 内置模块替代
- CMake 3.20+ 完全支持内置 Vulkan 查找

**改进建议：**
- 可以删除 `FindVulkan.cmake` 文件
- 或保留作为文档参考，但标记为废弃

### 2.3 使用现代 CMake Presets

**改进建议：**
- CMake 3.20+ 支持 `CMakePresets.json`
- 可添加预设文件简化配置：

```json
{
  "version": 3,
  "configurePresets": [
    {
      "name": "default",
      "binaryDir": "${sourceDir}/build",
      "cacheVariables": {
        "CMAKE_CXX_STANDARD": "20",
        "CMAKE_BUILD_TYPE": "Release"
      }
    },
    {
      "name": "debug",
      "inherits": "default",
      "cacheVariables": {
        "CMAKE_BUILD_TYPE": "Debug",
        "ENABLE_ASAN": "ON"
      }
    }
  ]
}
```

---

## 阶段三：架构优化

### 3.1 使用 INTERFACE 库封装配置

**当前问题：**
- 使用全局 `add_compile_definitions()` 和 `add_compile_options()`
- 难以在项目间隔离配置

**改进建议：**
```cmake
# 创建配置接口库
add_library(cm_config INTERFACE)

# 平台定义
target_compile_definitions(cm_config INTERFACE
    $<$<BOOL:${HGL_64_BITS}>:HGL_64_BITS>
    $<$<BOOL:${HGL_32_BITS}>:HGL_32_BITS>
)

# AVX2 支持
target_compile_options(cm_config INTERFACE
    $<$<CXX_COMPILER_ID:MSVC>:/arch:AVX2>
    $<$<CXX_COMPILER_ID:GNU,Clang>:-mavx2>
)

# 使用方式
target_link_libraries(my_target PRIVATE cm_config)
```

### 3.2 模块入口文件

**改进建议：**
- 添加 `CMakeLists.txt` 作为项目入口
- 便于作为子模块或 `FetchContent` 使用

```cmake
# CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project(CMCMakeModule VERSION 1.0.0 LANGUAGES CXX)

# 导出配置接口
add_library(CMCMakeModule INTERFACE)
add_library(CMCMakeModule::CMCMakeModule ALIAS CMCMakeModule)

# 包含模块路径
target_include_directories(CMCMakeModule INTERFACE
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
)
```

### 3.3 C++20 模块支持优化

**当前问题：**
- compiler.cmake 中的 C++20 模块标志可能导致非模块项目编译失败
- 第89-91行的 `/interface /ifcOutput` 标志只适用于模块接口单元

**改进建议：**
```cmake
# 将模块支持改为可选
option(ENABLE_CXX20_MODULES "Enable C++20 module support" OFF)

if(ENABLE_CXX20_MODULES AND CMAKE_VERSION VERSION_GREATER_EQUAL "3.28")
    set(CMAKE_CXX_SCAN_FOR_MODULES ON)
    # ... 模块相关设置
endif()
```

---

## 阶段四：功能增强

### 4.1 添加 .gitignore 文件

**改进建议：**
```gitignore
# Build directories
build/
out/
cmake-build-*/

# IDE files
.idea/
.vscode/
*.suo
*.user

# Generated files
CMakeUserPresets.json
```

### 4.2 添加版本信息

**改进建议：**
- 创建 `VERSION` 文件或在 `CMakeLists.txt` 中定义版本
- 添加 `CHANGELOG.md` 记录变更历史

### 4.3 README.md 增强

**改进建议：**
- 添加模块功能描述表格
- 添加技术要求说明（CMake 3.20+、C++20、AVX2）
- 添加更多使用示例

---

## 阶段五：持续集成

### 5.1 添加 GitHub Actions

**改进建议：**
```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]

jobs:
  build:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        cmake-version: ['3.20', '3.25', '3.28']
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Setup CMake
        uses: jwlawson/actions-setup-cmake@v2
        with:
          cmake-version: ${{ matrix.cmake-version }}
      - name: Configure
        run: cmake -B build -DCMAKE_CXX_STANDARD=20
      - name: Build
        run: cmake --build build
```

### 5.2 添加简单测试

**改进建议：**
- 创建 `test/` 目录
- 添加验证模块加载的测试项目

---

## 具体问题速查表

| 文件 | 位置 | 问题 | 优先级 | 状态 |
|------|------|------|--------|------|
| compiler.cmake | 第89-91行 | C++20 模块标志应设为可选 | 中 | 待处理 |
| - | - | 缺少 CMakeLists.txt 入口 | 中 | 待处理 |

---

## 已完成改进

- [x] README.md: 修正拼写错误 `target_link_libraried` → `target_link_libraries`
- [x] compiler.cmake: 修正 `endif(msvc)` → `endif()`
- [x] LICENSE: 添加 BSD-3-Clause 许可证
- [x] COPYING-CMAKE-SCRIPTS: 添加 BSD 许可证文件
- [x] 全局: 将 `add_definitions()` 替换为 `add_compile_definitions()`
- [x] vulkan.cmake: 使用 CMake 内置 FindVulkan 模块
- [x] 全局: 统一 CMake 命令为小写
- [x] vulkan.cmake: 移除 CMake 3.7 版本检查
- [x] compiler.cmake: 移除 CMake 3.15 版本检查
- [x] CMakePresets.json: 添加现代 CMake Presets 支持
- [x] .gitignore: 添加项目忽略文件

---

## 推荐实施顺序

1. **短期（1-2天）**：完成代码风格统一（阶段一）
2. **中期（1周）**：简化版本检查、添加基础设施文件（阶段二、四）
3. **长期（按需）**：架构优化和持续集成（阶段三、五）

---

## 参考资源

- [Modern CMake](https://cliutils.gitlab.io/modern-cmake/)
- [CMake 3.20 Release Notes](https://cmake.org/cmake/help/latest/release/3.20.html)
- [C++20 Modules in CMake](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html)
- [CMake Presets](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html)
