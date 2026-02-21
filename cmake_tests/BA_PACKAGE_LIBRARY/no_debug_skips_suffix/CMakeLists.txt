##
# Test: NO_DEBUG=ON skips debug suffix and build type keywords
#
# Verifies that BA_PACKAGE_LIBRARY with NO_DEBUG=ON does not add DEBUG/RELEASE
# keywords and does not append 'd' suffix even in Debug build mode.
#
IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.21)
    PROJECT(TEST_NO_DEBUG_SKIPS_SUFFIX)
ENDIF()

FIND_PACKAGE(CMLIB REQUIRED)

SET(MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_OUTPUT "https://example.com/main/mock_distro/0.0.0/mock_arch/mypkg/libmypkg-dev_v1.0.0_mock_arch_mock_distro_0.0.0.zip" CACHE INTERNAL "")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../include_general.cmake")

SET(CMAKE_BUILD_TYPE "Debug")
BA_PACKAGE_VARS_SET(REVISION "main")
BA_PACKAGE_VARS_SET(URI_TEMPLATE "https://example.com/<REVISION>/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>")
BA_PACKAGE_VARS_SET(GIT_PATH_TEMPLATE "")

BA_PACKAGE_LIBRARY(mypkg v1.0.0 NO_DEBUG ON)

TEST_VAR_TRUE(MOCK_CMLIB_DEPENDENCY_CALLED)

STRING(FIND "${MOCK_CMLIB_DEPENDENCY_URI}" "libmypkgd-dev" found_debug_suffix)
IF(NOT found_debug_suffix EQUAL -1)
    MESSAGE(FATAL_ERROR "URI should NOT contain 'd-dev' suffix when NO_DEBUG=ON: ${MOCK_CMLIB_DEPENDENCY_URI}")
ENDIF()

STRING(FIND "${MOCK_CMLIB_DEPENDENCY_URI}" "libmypkg-dev" found_release_suffix)
IF(found_release_suffix EQUAL -1)
    MESSAGE(FATAL_ERROR "URI should contain '-dev' suffix (no 'd'): ${MOCK_CMLIB_DEPENDENCY_URI}")
ENDIF()

LIST(FIND MOCK_CMLIB_DEPENDENCY_KEYWORDS "RELEASE" idx_release)
IF(NOT idx_release EQUAL -1)
    MESSAGE(FATAL_ERROR "KEYWORDS should NOT contain RELEASE when NO_DEBUG=ON: ${MOCK_CMLIB_DEPENDENCY_KEYWORDS}")
ENDIF()

LIST(FIND MOCK_CMLIB_DEPENDENCY_KEYWORDS "DEBUG" idx_debug)
IF(NOT idx_debug EQUAL -1)
    MESSAGE(FATAL_ERROR "KEYWORDS should NOT contain DEBUG when NO_DEBUG=ON: ${MOCK_CMLIB_DEPENDENCY_KEYWORDS}")
ENDIF()

