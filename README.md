# CMCMakeModule
CM CMake module file

## use

 - create a project
 - run "git submodule add https://github.com/hyzboy/CMCMakeModule" in project root directory.
 - run "git submodule add https://github.com/hyzboy/CMCore"
 - run "git submodule add https://github.com/hyzboy/CMPlatform"
 - add the following code to project CMakeLists.txt
``` 
   cmake_minimum_required(VERSION 3.0)
   
   project(SampleProject)
   
   set_property(GLOBAL PROPERTY USE_FOLDERS ON)
  
   set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMCMakeModule)
  
   include(math)
   use_mgl(${CMAKE_CURRENT_SOURCE_DIR}/3rdpty/MathGeoLib)
  
   include(use_cm_module)
   use_cm_module(Core)
   use_cm_module(Platform)
```
