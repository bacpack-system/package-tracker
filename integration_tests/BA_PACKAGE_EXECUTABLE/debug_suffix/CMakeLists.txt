##
# Test: Debug build adds only 'd' suffix for executable package (no '-dev')
#
# Verifies that BA_PACKAGE_EXECUTABLE in Debug mode produces a URI with 'd' suffix
# but without "lib" prefix and without "-dev" (e.g., mypkgd_v1.0.0 not libmypkgd-dev_v1.0.0).
#
IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.21)
    PROJECT(TEST_EXEC_DEBUG_SUFFIX)
ENDIF()

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../include_general.cmake")

SET(CMAKE_BUILD_TYPE "Debug")
BA_PACKAGE_VARS_SET(REVISION "main")
BA_PACKAGE_VARS_SET(URI_TEMPLATE "https://example.com/<REVISION>/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>")
BA_PACKAGE_VARS_SET(GIT_PATH_TEMPLATE "")

# Make sure the mypkg does not contain any keywords tested below
BA_PACKAGE_EXECUTABLE(mypkg v1.0.0)

TEST_VAR_TRUE(MOCK_CMLIB_DEPENDENCY_CALLED)

STRING(FIND "${MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_ARCHIVE_NAME}" "mypkgd_v1.0.0" found_debug_suffix)
IF(found_debug_suffix EQUAL -1)
    MESSAGE(FATAL_ERROR "ARCHIVE_NAME does not contain 'mypkgd_v1.0.0': ${MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_ARCHIVE_NAME}")
ENDIF()

STRING(FIND "${MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_ARCHIVE_NAME}" "lib" found_lib)
IF(NOT found_lib EQUAL -1)
    MESSAGE(FATAL_ERROR "ARCHIVE_NAME should not contain 'lib': ${MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_ARCHIVE_NAME}")
ENDIF()

STRING(FIND "${MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_ARCHIVE_NAME}" "-dev" found_dev)
IF(NOT found_dev EQUAL -1)
    MESSAGE(FATAL_ERROR "ARCHIVE_NAME should not contain '-dev': ${MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_ARCHIVE_NAME}")
ENDIF()

