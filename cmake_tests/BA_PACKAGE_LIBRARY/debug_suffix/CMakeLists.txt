##
# Test: Debug build adds 'd' suffix to package name and DEBUG keyword
#
# Verifies that BA_PACKAGE_LIBRARY in Debug mode adds DEBUG keyword and
# appends 'd' suffix to the package name in the URI (e.g., libmypkgd-dev).
#
IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.21)
    PROJECT(TEST_DEBUG_SUFFIX)
ENDIF()

FIND_PACKAGE(CMLIB REQUIRED)

SET(MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_OUTPUT "https://example.com/main/mock_distro/0.0.0/mock_arch/mypkg/libmypkgd-dev_v1.0.0_mock_arch_mock_distro_0.0.0.zip" CACHE INTERNAL "")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../include_general.cmake")

SET(CMAKE_BUILD_TYPE "Debug")
BA_PACKAGE_VARS_SET(REVISION "main")
BA_PACKAGE_VARS_SET(URI_TEMPLATE "https://example.com/<REVISION>/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>")
BA_PACKAGE_VARS_SET(GIT_PATH_TEMPLATE "")

BA_PACKAGE_LIBRARY(mypkg v1.0.0)

TEST_VAR_TRUE(MOCK_CMLIB_DEPENDENCY_CALLED)

STRING(FIND "${MOCK_CMLIB_DEPENDENCY_URI}" "libmypkgd-dev" found_debug_suffix)
IF(found_debug_suffix EQUAL -1)
    MESSAGE(FATAL_ERROR "URI does not contain 'd-dev' suffix: ${MOCK_CMLIB_DEPENDENCY_URI}")
ENDIF()

