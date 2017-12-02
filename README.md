## `generate_git_version_header()` - a CMake function to include the current git commit id and branch in a C/C++ project

I have seen various projects that in someway include the sha1 id of the
current commit into their application. A popular approach is to parse
`.git/HEAD` with CMake means (e.g. `file()`) and write the current commit id
to a CMake variable. A downside of this approach is that it does this when
a project is (re)configured. But not all new commits trigger reconfiguring
(e.g. if only the contents of some source files change). This can be
overcome by forcing CMake to reconfigure on every new git commit (an
implementation for this can be found at https://github.com/rpavlik/cmake-modules/blob/master/GetGitRevisionDescription.cmake).
However reconfiguring may be very expensive depending on the size of your
project. So I propose a solution that adds an explicit build step
(with `add_custom_command()`) that runs on every build but is very cheap.

### Usage

`generate_git_version_header()` expects the name of the header to generate as
parameter. The generated header defines `GIT_SHA1` (a string literal containing
the commit id) and `GIT_BRANCH` (a string literal containing the name of the
current branch).

    include(GitVersionHeader)

    set(GIT_VERSION_HEADER ${CMAKE_CURRENT_BINARY_DIR}/git_info.h)
    generate_git_version_header(${GIT_VERSION_HEADER})

    add_executable(cmake_git_version main.cpp ${GIT_VERSION_HEADER})
    target_include_directories(cmake_git_version PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

