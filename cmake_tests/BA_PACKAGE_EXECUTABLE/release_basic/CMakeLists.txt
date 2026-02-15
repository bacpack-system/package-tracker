##
# Test: Release build uses empty prefix and empty suffix for executable package
#
# Verifies that BA_PACKAGE_EXECUTABLE in Release mode produces a URI without
# "lib" prefix and without "-dev" suffix (e.g., mypkg_v1.0.0 not libmypkg-dev_v1.0.0).
#
IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.21)
    PROJECT(TEST_EXEC_RELEASE_BASIC)
ENDIF()

FIND_PACKAGE(CMLIB REQUIRED)

SET(MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_OUTPUT "https://example.com/main/mock_distro/0.0.0/mock_arch/mypkg/mypkg_v1.0.0_mock_arch_mock_distro_0.0.0.zip" CACHE INTERNAL "")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../BA_PACKAGE_LIBRARY/include_general.cmake")

SET(CMAKE_BUILD_TYPE "Release")
BA_PACKAGE_VARS_SET(REVISION "main")
BA_PACKAGE_VARS_SET(URI_TEMPLATE "https://example.com/<REVISION>/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>")
BA_PACKAGE_VARS_SET(GIT_PATH_TEMPLATE "")

# Make sure the mypkg does not contain any keywords tested below
BA_PACKAGE_EXECUTABLE(mypkg v1.0.0)

TEST_VAR_TRUE(MOCK_CMLIB_DEPENDENCY_CALLED)

STRING(FIND "${MOCK_CMLIB_DEPENDENCY_URI}" "mypkg_v1.0.0" found_pkg)
IF(found_pkg EQUAL -1)
    MESSAGE(FATAL_ERROR "URI does not contain 'mypkg_v1.0.0': ${MOCK_CMLIB_DEPENDENCY_URI}")
ENDIF()

STRING(FIND "${MOCK_CMLIB_DEPENDENCY_URI}" "lib" found_lib)
IF(NOT found_lib EQUAL -1)
    MESSAGE(FATAL_ERROR "URI should not contain 'lib' prefix: ${MOCK_CMLIB_DEPENDENCY_URI}")
ENDIF()

STRING(FIND "${MOCK_CMLIB_DEPENDENCY_URI}" "-dev" found_dev)
IF(NOT found_dev EQUAL -1)
    MESSAGE(FATAL_ERROR "URI should not contain '-dev' suffix: ${MOCK_CMLIB_DEPENDENCY_URI}")
ENDIF()

