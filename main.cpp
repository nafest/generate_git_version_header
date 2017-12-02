#include "git_info.h"
#include <iostream>

int main(int argc, const char* argv[])
{
    std::cout << GIT_SHA1 << " on " << GIT_BRANCH << std::endl;
}
