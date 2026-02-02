# CMCMakeModule
CMake module files of CMGameEngine/ULRE

## use

 - create a project
 - switch to the project root directory using the console/bash/GIT Bash
 - run the following command
```
 git submodule add https://github.com/hyzboy/CMCMakeModule
 git submodule add https://github.com/hyzboy/CMCore
 git submodule add https://github.com/hyzboy/CMPlatform
 git submodule add https://github.com/hyzboy/CMUtil
```
 - add the following code to project CMakeLists.txt
```
   cmake_minimum_required(VERSION 3.28)

   project(YourProject)

   set_property(GLOBAL PROPERTY USE_FOLDERS ON)

   set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMCMakeModule)

   #if you use Vulkan API
   include(vulkan)

   include(math)
   use_mgl(${CMAKE_CURRENT_SOURCE_DIR}/3rdpty/MathGeoLib)

   include(use_cm_module)
   use_cm_module(Core)
   use_cm_module(Platform)
   use_cm_module(Util)

   ...

   add_executable(YourProgram ...)
   target_link_libraries(YourProgram CMCore CMPlatform)

   #if you use vulkan render
   target_link_libraries(YourProject ${RENDER_LIBRARY} ${Vulkan_LIBRARIES})

```
