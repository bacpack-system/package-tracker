IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.21)
    PROJECT(BA_PACKAGE_PREREQ_CMCONF_INIT_TEST)
ENDIF()

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_local_use_on")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_local_use_off")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_env_var_precedence")

TEST_RUN_AND_CHECK_OUTPUT("test_env_var_with_local_use_warning"
    WARNING_MESSAGE "BA_PACKAGE_LOCAL_PATH ENV variable is defined"
    ALWAYS_SCRIPT_MODE ON
)

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/test_invalid_local_path"
    "Local repository path variable is not"
)

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/test_revision_with_local_warning")

