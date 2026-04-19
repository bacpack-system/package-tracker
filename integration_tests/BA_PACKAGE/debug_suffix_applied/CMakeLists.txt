##
# Test: Prefix and suffix are applied to the package name
#
# Verifies that BA_PACKAGE constructs the expanded package name as
# prefix + package_name + suffix (e.g., "myprefixmypkgmysuffix").
#
IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.21)
    PROJECT(TEST_BA_PACKAGE_DEBUG_SUFFIX_APPLIED)
ENDIF()

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../include_general.cmake")

SET(CMAKE_BUILD_TYPE "Release")
BA_PACKAGE_VARS_SET(REVISION "main")
BA_PACKAGE_VARS_SET(URI_TEMPLATE "https://example.com/<REVISION>/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>")
BA_PACKAGE_VARS_SET(GIT_PATH_TEMPLATE "")

BA_PACKAGE(mypkg v1.0.0 "myprefix" "mysuffix" output_path)

TEST_VAR_TRUE(MOCK_CMLIB_DEPENDENCY_CALLED)

STRING(FIND "${MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_ARCHIVE_NAME}" "myprefixmypkgmysuffix" found_expanded)
IF(found_expanded EQUAL -1)
    MESSAGE(FATAL_ERROR "ARCHIVE_NAME should contain 'myprefixmypkgmysuffix': ${MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_ARCHIVE_NAME}")
ENDIF()

