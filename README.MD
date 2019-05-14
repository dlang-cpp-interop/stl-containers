dmd [![Build Status](https://travis-ci.org/dlang-cpp-interop/stl-containers.svg?branch=master)](https://travis-ci.org/dlang-cpp-interop/stl-containers)

https://github.com/dlang/druntime/pull/2448

https://github.com/dlang/druntime/pull/2456

https://github.com/dlang/druntime/pull/2310


TODO:

1. Travis Windows environment does not have a D compiler by default so it needs to be installed in the .travis.yml config file
2. #include for size_t on Linux
3. implementation for various containers on Linux not yet done/finished
4. osx, freebsd impl and build not done at all I think
5. implement unordered map, set
6. it's not really STL, but boost::optional
7. add build badge matrix for linux/windows/osx dmd/ldc/gdc
