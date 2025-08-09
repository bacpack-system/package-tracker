#
# BringAuto BA_PACKAGE example.
#
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)
PROJECT(BA_PACKAGE_EXAMPLE CXX)

#
# We initialize CMLIB library.
# If you do not have one just follow https://github.com/cmakelib/cmakelib
#
FIND_PACKAGE(CMLIB
    COMPONENTS STORAGE CMDEF
    REQUIRED
)

#
#
# Let's implement a basic example of how to use BA_PACKAGE
# using CURL and Zlib as an example.
#
BA_PACKAGE_LIBRARY(zlib v1.2.11 OUTPUT_PATH_VAR ZLIB_ROOT)
BA_PACKAGE_LIBRARY(curl v7.79.1)

#
# After adding the package we can use standard FIND_LIBRARY
# as documented by the package upstream
#
FIND_PACKAGE(ZLIB REQUIRED)
FIND_PACKAGE(CURL REQUIRED)

# The RPATH to the install path of dependencies
# is updated manually....
# 
SET(CMAKE_INSTALL_RPATH "$ORIGIN/../lib")

CMDEF_ADD_EXECUTABLE(
    TARGET test
    SOURCES main.cpp
    VERSION 1.8.5
)
TARGET_LINK_LIBRARIES(test PUBLIC ZLIB::ZLIB CURL::libcurl)

# Install created target
CMDEF_INSTALL(TARGET test
    NAMESPACE test::
)

# Install all shared library dependencies needed for json_target
# and update RUNPATH.
BA_PACKAGE_DEPS_IMPORTED(test)

# Create a package
CMDEF_PACKAGE(
    MAIN_TARGET test
    VERSION     1.0.9
)

SET(CPACK_GENERATOR ZIP)
INCLUDE(CPack)