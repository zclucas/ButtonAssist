
cmake_minimum_required(VERSION 3.10)
project(demo)

# 设置C++11标准
set(CMAKE_CXX_STANDARD 11)

# 查找OpenCV
find_package(OpenCV REQUIRED)
include_directories(${OpenCV_INCLUDE_DIRS})

if(MSVC)
    add_compile_options(/utf-8)
    add_definitions(-DUNICODE -D_UNICODE)
endif()

# 添加导出宏定义
# add_definitions(-DIMAGEFINDER_EXPORTS)

# 创建进程
add_executable(demo main.cpp ../ImageFinder.cpp ../ImageFinder.h)

# 链接OpenCV库
target_link_libraries(demo ${OpenCV_LIBS})