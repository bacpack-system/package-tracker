IF(NOT DEFINED CMAKE_SCRIPT_MODE_FILE)
    CMAKE_MINIMUM_REQUIRED(VERSION 3.21)
    PROJECT(BA_PACKAGE_PREREQ_CMCONF_INIT_TEST)
ENDIF()

FIND_PACKAGE(CMLIB REQUIRED)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../TEST.cmake")

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/local_use_on")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/local_use_off")
TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/env_var_precedence")

TEST_RUN_AND_CHECK_OUTPUT("env_var_with_local_use_warning"
    WARNING_MESSAGE "BA_PACKAGE_LOCAL_PATH ENV variable is defined and BA_PACKAGE_LOCAL_USE is.*ON.*Using BA_PACKAGE_LOCAL_PATH ENV variable to set as Repository path"
    ALWAYS_SCRIPT_MODE ON
)

TEST_RUN_AND_CHECK_OUTPUT("git_archive_with_http_header_warning"
    WARNING_MESSAGE "BA_PACKAGE_HTTP_AUTHORIZATION_HEADER is defined together with.*BA_PACKAGE_GIT_ARCHIVE_PATH_TEMPLATE.*ARCHIVE_PATH_TEMPLATE implies the.*URI type is GIT but HTTP_HEADERS are used only for raw HTTP Downloads"
    ALWAYS_SCRIPT_MODE ON
)

TEST_RUN("${CMAKE_CURRENT_LIST_DIR}/git_archive_path_returned")

TEST_INVALID_CMAKE_RUN("${CMAKE_CURRENT_LIST_DIR}/invalid_local_path"
    "Local repository path variable is not a directory"
)

