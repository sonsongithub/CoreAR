project(CoreARTest)

# 2.6.3 is needed for ctest support
cmake_minimum_required(VERSION 2.8)

enable_testing()
include(CTest)

include_directories(${PROJECT_SOURCE_DIR}/../)
include_directories(${PROJECT_SOURCE_DIR}/../include)
include_directories(${PROJECT_SOURCE_DIR}/../cpputest/include/)

ADD_EXECUTABLE(CoreARTest main.cpp test.cpp)

target_link_libraries(CoreARTest CppUTest CoreAR)

add_test(CoreARTest ${CMAKE_CURRENT_BINARY_DIR}/CoreARTest)