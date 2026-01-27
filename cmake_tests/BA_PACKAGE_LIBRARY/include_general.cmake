##
# Common includes for BA_PACKAGE_LIBRARY tests
#
# Provides standard test setup including VARS, TEST framework, BA_PACKAGE modules,
# and all standard mocks (CMDEF_VARS, CMUTIL, CMLIB_STORAGE, CMLIB_DEPENDENCY).
#
# Does NOT include CMLIB_CACHE mock - tests requiring CACHE_ONLY must include it separately.
#
# Note: If test needs custom MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_OUTPUT,
# set it BEFORE including this file.
#

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../VARS.cmake")
INCLUDE("${CMAKE_TESTS_ROOT}/TEST.cmake")

INCLUDE("${PACKAGER_PROJECT_ROOT}/BA_PACKAGE_VARS.cmake")
INCLUDE("${PACKAGER_PROJECT_ROOT}/BA_PACKAGE.cmake")

INCLUDE("${CMAKE_TESTS_ROOT}/mock/CMDEF_VARS.cmake")
INCLUDE("${CMAKE_TESTS_ROOT}/mock/CMUTIL.cmake")
INCLUDE("${CMAKE_TESTS_ROOT}/mock/CMLIB_STORAGE.cmake")
INCLUDE("${CMAKE_TESTS_ROOT}/mock/CMLIB_DEPENDENCY.cmake")

