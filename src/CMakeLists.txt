project(libCoreAR)

# 2.6.3 is needed for ctest support
cmake_minimum_required(VERSION 2.8)

include_directories(${PROJECT_SOURCE_DIR}/../)

ADD_LIBRARY(CoreAR STATIC CoreAR.cpp)