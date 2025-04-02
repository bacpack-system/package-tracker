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
# Add package by a name specified in the registry:
#   https://gitlab.bringauto.com/bringauto-public/fleet-package-repository
#
# nlohman-json library does not differ between Release and Debug configuration,
# That's why we need to explicitly tell the BA_PACKAGE - "nlohman-json has no debug version of the lib" .
#
# Otherwise the curl has a shared library and it differs between Debug and Release
#
BA_PACKAGE_LIBRARY(nlohmann-json v3.10.5 NO_DEBUG ON)
BA_PACKAGE_LIBRARY(curl          v7.79.1)

#
# After package add we can use standard FIND_LIBRARY
# as a documented by the package upstream
#
FIND_PACKAGE(nlohmann_json REQUIRED)
FIND_PACKAGE(CURL          REQUIRED)

# We need to update RPATH to install path of dependencicies
SET(CMAKE_INSTALL_RPATH "$ORIGIN/../lib")

CMDEF_ADD_EXECUTABLE(
    TARGET test
    SOURCES main.cpp
    VERSION 1.8.5
)
TARGET_LINK_LIBRARIES(test PUBLIC nlohmann_json::nlohmann_json CURL::libcurl)

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