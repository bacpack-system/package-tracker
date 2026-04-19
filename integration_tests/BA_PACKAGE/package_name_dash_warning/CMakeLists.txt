##
# Test: Package name with dashes emits normalization warning
#
# Verifies that BA_PACKAGE emits a WARNING when the package name
# contains invalid characters (like dashes) that are normalized for CMLIB keywords.
#
IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.21)
    PROJECT(TEST_BA_PACKAGE_PACKAGE_NAME_DASH_WARNING)
ENDIF()

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../include_general.cmake")

SET(CMAKE_BUILD_TYPE "Release")
BA_PACKAGE_VARS_SET(REVISION "main")
BA_PACKAGE_VARS_SET(URI_TEMPLATE "https://example.com/<REVISION>/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>")
BA_PACKAGE_VARS_SET(GIT_PATH_TEMPLATE "")

BA_PACKAGE(my-pkg v1.0.0 "" "" output_path)

TEST_VAR_TRUE(MOCK_CMLIB_DEPENDENCY_CALLED)

