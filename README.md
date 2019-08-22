# CMCMakeModule
CM CMake module file

1.create root project

2.run "git submodule add https://github.com/hyzboy/CMCMakeModule" in project root directory.

3.add the following code to project CMakeLists.txt
  
  set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/CMCMakeModule)

  #include(math)
  #use_mgl(${CMAKE_CURRENT_SOURCE_DIR}/3rdpty/MathGeoLib)

  include(use_cm_module)
  use_cm_module(Core)
