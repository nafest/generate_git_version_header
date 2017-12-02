# Copyright (c) 2017, Stefan Winkler
# License: MIT License (for full license see LICENSE)

cmake_minimum_required(VERSION 3.8 FATAL_ERROR)

project(cmake_git_version)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include(GitVersionHeader)

set(GIT_VERSION_HEADER ${CMAKE_CURRENT_BINARY_DIR}/git_info.h)
generate_git_version_header(${GIT_VERSION_HEADER})

add_executable(cmake_git_version main.cpp ${GIT_VERSION_HEADER})
target_include_directories(cmake_git_version PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
