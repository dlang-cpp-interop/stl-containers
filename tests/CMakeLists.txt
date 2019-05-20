cmake_minimum_required(VERSION 3.0.0 FATAL_ERROR)

project("stl_container_test" D)

set(CMAKE_VERBOSE_MAKEFILE ON)

set(files "allocator_test.d"  "array_test.d"  "new_test.d"  "string_test.d"   "vector_test.d")
target_link_directories(stl_container_test stl_container_test_cpp .)

if(WIN32)
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT")
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd")
endif()
