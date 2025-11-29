# CMCMakeModule 改进意见

本文档提供了对 CMCMakeModule 仓库的改进意见，按优先级和复杂度分阶段组织，便于逐步推进。

---

## 阶段一：基础改进（低风险、高价值）

### 1.1 README.md 完善

**当前问题：**
- README 内容较简单，缺乏详细说明
- 存在拼写错误（第42行 `target_link_libraried` 应为 `target_link_libraries`）
- 缺少模块功能说明和使用示例

**改进建议：**
- 添加各模块功能描述表格
- 添加 CMake 版本要求说明
- 添加更多使用示例
- 添加贡献指南和许可证说明
- 修正拼写错误

### 1.2 添加 LICENSE 文件

**当前问题：**
- 缺少许可证文件
- 部分 Find*.cmake 文件引用了 BSD 许可证但未提供

**改进建议：**
- 添加合适的开源许可证（如 MIT 或 BSD-3-Clause）
- 添加被引用的 COPYING-CMAKE-SCRIPTS 文件

### 1.3 添加 .gitignore 文件

**当前问题：**
- 缺少 .gitignore 文件

**改进建议：**
- 添加 .gitignore 排除常见的构建产物和IDE文件

---

## 阶段二：代码质量改进（中等风险）

### 2.1 CMake 代码风格统一

**当前问题：**
- 命令大小写不一致（IF/if, SET/set, ELSE/else 混用）
- 注释语言不统一（中英文混合）
- 缩进风格不一致

**改进建议：**
- 统一使用小写 CMake 命令（现代 CMake 风格）
- 统一注释语言（建议英文）
- 统一缩进风格（4空格或2空格）

### 2.2 compiler.cmake 改进

**当前问题：**
- 第39行大小写错误：`endif(msvc)` 应为 `endif(MSVC)` 或 `endif()`
- 第75行 `find_package(tsl-robin-map CONFIG REQUIRED)` 可能导致项目不可用（硬依赖第三方库）
- 第89-91行的 MSVC C++20 模块标志可能会在非模块项目中导致编译错误
- 一些编译选项（如 /arch:AVX2）可能在老旧硬件上无法运行

**改进建议：**
```cmake
# 将硬依赖改为可选依赖
option(USE_TSL_ROBIN_MAP "Use tsl-robin-map for hash maps" OFF)
if(USE_TSL_ROBIN_MAP)
    find_package(tsl-robin-map CONFIG REQUIRED)
endif()

# AVX2 应该作为可选项
option(ENABLE_AVX2 "Enable AVX2 instructions" ON)
```

### 2.3 version.cmake 改进

**当前问题：**
- 使用已过时的 `add_definitions()` 命令

**改进建议：**
- 使用现代 CMake 的 `add_compile_definitions()` 或 `target_compile_definitions()`

### 2.4 math.cmake 改进

**当前问题：**
- 使用已过时的 `add_definitions()` 命令
- 硬性要求 glm 库，可能导致项目不可用

**改进建议：**
- 改为可选依赖，或提供清晰的错误信息

---

## 阶段三：功能增强（中等复杂度）

### 3.1 添加 CMake 版本检查

**改进建议：**
- 在主模块入口添加最低版本要求检查
- 对于高版本特性（如 C++20 模块支持）提供优雅的降级

### 3.2 添加安装支持

**当前问题：**
- 没有 install() 规则
- 无法作为系统级模块安装

**改进建议：**
- 添加 CMakeLists.txt 作为项目入口
- 支持 `cmake --install` 和 `find_package(CMCMakeModule)`

### 3.3 添加测试框架

**当前问题：**
- 没有任何测试验证模块功能

**改进建议：**
- 添加简单的 CMake 测试项目验证模块加载
- 可使用 ctest 进行自动化测试

### 3.4 Find*.cmake 模块改进

**当前问题：**
- FindVulkan.cmake 与 CMake 内置的可能冲突（CMake 3.7+ 已内置）
- 应该优先使用 CMake 内置模块

**改进建议：**
```cmake
# 优先使用 CMake 内置模块
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.7")
    find_package(Vulkan)
else()
    # 回退到自定义实现
    include(${CMAKE_CURRENT_LIST_DIR}/FindVulkan.cmake)
endif()
```

---

## 阶段四：架构优化（高复杂度）

### 4.1 模块化重构

**当前问题：**
- 模块之间耦合度较高
- use_cm_module.cmake 隐式包含了多个模块

**改进建议：**
- 创建独立的模块接口
- 允许用户选择性加载所需模块

### 4.2 现代 CMake 最佳实践

**改进建议：**
- 使用 target-based 方式替代全局变量
- 创建 IMPORTED 目标便于依赖管理
- 使用生成器表达式替代条件编译

示例：
```cmake
# 旧方式
add_definitions(-DHGL_64_BITS)

# 新方式
add_library(hgl_config INTERFACE)
target_compile_definitions(hgl_config INTERFACE HGL_64_BITS)
```

### 4.3 文档生成

**改进建议：**
- 添加 RST/Markdown 文档
- 考虑使用 Sphinx 或 MkDocs 生成文档网站

---

## 阶段五：持续集成（可选）

### 5.1 添加 CI/CD 配置

**改进建议：**
- 添加 GitHub Actions 工作流
- 在多平台（Windows/Linux/macOS）测试模块
- 添加 CMake 版本矩阵测试

示例 `.github/workflows/ci.yml`：
```yaml
name: CI
on: [push, pull_request]
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest, macos-latest]
        cmake-version: ['3.19', '3.25', '3.28']
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - name: Setup CMake
        uses: jwlawson/actions-setup-cmake@v2
        with:
          cmake-version: ${{ matrix.cmake-version }}
      - name: Test
        run: cmake -P test/run_tests.cmake
```

> 注意：建议使用 CMake 3.19+ 作为基线版本，因为该版本引入了许多现代 CMake 特性。

### 5.2 版本管理

**改进建议：**
- 添加版本号文件
- 使用 Git tags 进行版本发布
- 添加 CHANGELOG.md 记录变更

---

## 具体问题速查表

| 文件 | 行号 | 问题 | 严重程度 | 修复建议 |
|------|------|------|----------|----------|
| README.md | 42 | 拼写错误 `target_link_libraried` | 低 | 改为 `target_link_libraries` |
| compiler.cmake | 39 | 大小写不一致 `endif(msvc)` | 低 | 改为 `endif()` |
| compiler.cmake | 75 | 硬性依赖 tsl-robin-map | 中 | 改为可选依赖 |
| compiler.cmake | 89-91 | C++20 模块标志可能导致编译错误 | 中 | 添加条件判断 |
| version.cmake | 全文 | 使用过时的 add_definitions | 低 | 使用 add_compile_definitions |
| system_bit.cmake | 全文 | 使用过时的 add_definitions | 低 | 使用 add_compile_definitions |
| math.cmake | 全文 | 使用过时的 add_definitions | 低 | 使用 add_compile_definitions |
| vulkan.cmake | 全文 | 使用过时的 add_definitions | 低 | 使用 add_compile_definitions |

---

## 推荐实施顺序

1. **第一周**：完成阶段一的所有改进
2. **第二周**：逐步完成阶段二的代码质量改进
3. **第三周**：开始阶段三的功能增强
4. **后续**：根据项目需求选择性实施阶段四和五

---

## 参考资源

- [Modern CMake](https://cliutils.gitlab.io/modern-cmake/)
- [CMake Best Practices](https://cmake.org/cmake/help/latest/manual/cmake-developer.7.html)
- [Professional CMake](https://crascit.com/professional-cmake/)
