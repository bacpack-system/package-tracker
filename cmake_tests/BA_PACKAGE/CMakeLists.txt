IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.21)
    PROJECT(BA_PACKAGE_TEST)
ENDIF()

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/release_basic")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/debug_keyword")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/debug_suffix_applied")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/no_debug_skips_keyword")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/git_path_template_args")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/no_git_args_without_template")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/cache_only_skips_dependency")

TEST_RUN_AND_CHECK_OUTPUT("package_name_dash_warning"
    WARNING_MESSAGE "Package name.*contains invalid characters.*normalized"
    ALWAYS_SCRIPT_MODE ON
)

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/invalid_package_name_error"
    "Invalid package name"
)

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/cache_only_not_found_error"
    "Package not found"
)

