# Copyright (c) 2017, Stefan Winkler
# License: MIT License (for full license see LICENSE)

# generate_git_version_header
#
# Generates a C/C++ header containing defines for the current
# git commit id (GIT_SHA1) and the current git branch (GIT_BRANCH).
# The name and location of this header must be passed as first argument,
# e.g.
#     generate_git_version_header(${CMAKE_CURRENT_BINARY_DIR}/git_info.h)
#
# generate_git_version_header creates a custom command, which ensures
# that the version header is updated on every rebuild, if necessary.
function(generate_git_version_header GIT_VERSION_HEADER)
    find_package(Git)

    set(GIT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/.git)
    set(GIT_VERSION_HEADER_TMP ${CMAKE_CURRENT_BINARY_DIR}/git_info/git_info.h_tmp)
    if(WIN32)
        set(GIT_VERSION_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/git_info/git_info.bat)
    else()
        set(GIT_VERSION_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/git_info/git_info.sh)
    endif()

    if(NOT WIN32)
        set(_QUOTES "\"")
    endif()

    file(WRITE ${GIT_VERSION_SCRIPT}
        "echo ${_QUOTES}#ifndef GIT_VERSION_HEADER${_QUOTES} > ${GIT_VERSION_HEADER_TMP}\n")
    file(APPEND ${GIT_VERSION_SCRIPT}
        "echo ${_QUOTES}#define GIT_VERSION_HEADER${_QUOTES} >> ${GIT_VERSION_HEADER_TMP}\n")
    if(Git_FOUND)
        if(WIN32)
            file(APPEND ${GIT_VERSION_SCRIPT}
                "setlocal enabledelayedexpansion\n")
            file(APPEND ${GIT_VERSION_SCRIPT}
                "FOR /F \"delims=\" %%i IN ('\"${GIT_EXECUTABLE}\" log -1 --pretty^=format:%%H') DO set sha1=%%i\n")
            file(APPEND ${GIT_VERSION_SCRIPT}
                "echo #define GIT_SHA1_PLAIN %sha1% >> ${GIT_VERSION_HEADER_TMP}\n")
            file(APPEND ${GIT_VERSION_SCRIPT}
                "FOR /F \"delims=\" %%i IN ('\"${GIT_EXECUTABLE}\" rev-parse --abbrev-ref HEAD') DO set branch=%%i\n")
            file(APPEND ${GIT_VERSION_SCRIPT}
                "echo #define GIT_BRANCH_PLAIN %branch% >> ${GIT_VERSION_HEADER_TMP}\n")
        else()
            file(APPEND ${GIT_VERSION_SCRIPT}
                "echo ${_QUOTES}#define GIT_SHA1_PLAIN `${GIT_EXECUTABLE} log -1 --pretty=format:${_QUOTES}%H${_QUOTES}`${_QUOTES} >> ${GIT_VERSION_HEADER_TMP}\n")
            file(APPEND ${GIT_VERSION_SCRIPT}
                "echo ${_QUOTES}#define GIT_BRANCH_PLAIN `${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD`${_QUOTES} >> ${GIT_VERSION_HEADER_TMP}\n")
        endif()
    else()
        file(APPEND ${GIT_VERSION_SCRIPT}
            "echo ${_QUOTES}#define GIT_SHA1_PLAIN no_git_executable_found${_QUOTES} >> ${GIT_VERSION_HEADER_TMP}\n")
        file(APPEND ${GIT_VERSION_SCRIPT}
            "echo ${_QUOTES}#define GIT_BRANCH_PLAIN no_git_executable_found${_QUOTES} >> ${GIT_VERSION_HEADER_TMP}\n")
    endif()
    file(APPEND ${GIT_VERSION_SCRIPT}
        "echo ${_QUOTES}#define __XGIT_STR(X) #X${_QUOTES} >> ${GIT_VERSION_HEADER_TMP}\n")
    file(APPEND ${GIT_VERSION_SCRIPT}
        "echo ${_QUOTES}#define __GIT_STR(X) __XGIT_STR(X)${_QUOTES} >> ${GIT_VERSION_HEADER_TMP}\n")
    file(APPEND ${GIT_VERSION_SCRIPT}
        "echo ${_QUOTES}#define GIT_SHA1 __GIT_STR(GIT_SHA1_PLAIN)${_QUOTES} >> ${GIT_VERSION_HEADER_TMP}\n")
    file(APPEND ${GIT_VERSION_SCRIPT}
        "echo ${_QUOTES}#define GIT_BRANCH __GIT_STR(GIT_BRANCH_PLAIN)${_QUOTES} >> ${GIT_VERSION_HEADER_TMP}\n")
    file(APPEND ${GIT_VERSION_SCRIPT} "echo ${_QUOTES}#endif${_QUOTES} >> ${GIT_VERSION_HEADER_TMP}\n")

    if(WIN32)
        set(_SH call)
    else()
        set(_SH sh)
    endif()

    # Add an output that is never generated to this custom command, such that it is
    # triggered on every build. copy_if_different ensures that rebuilds are only
    # necessary if the commit id and or branch change.
    add_custom_command(OUTPUT ${GIT_VERSION_HEADER}
        COMMAND ${_SH} ${GIT_VERSION_SCRIPT}
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${GIT_VERSION_HEADER_TMP} ${GIT_VERSION_HEADER}
        COMMAND ${CMAKE_COMMAND} -E remove ${GIT_VERSION_HEADER_TMP}
        DEPENDS ${GIT_DIR}/HEAD ${GIT_DIR}/index
        COMMENT "Update git version header ${GIT_VERSION_HEADER}")
endfunction()

