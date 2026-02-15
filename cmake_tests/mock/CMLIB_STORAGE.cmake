##
#
# Mock CMLIB_STORAGE module for testing BA_PACKAGE_LIBRARY URI template expansion
#
# This mock replaces CMLIB_STORAGE_TEMPLATE_INSTANCE to return configurable URIs
# without performing actual template expansion. Allows tests to verify URI
# construction and control the expanded URI value.
#
# Captured variables (CACHE INTERNAL):
#   MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_CALLED       - TRUE if function was called
#   MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_TEMPLATE_VAR - Name of template variable passed
#
# Configuration:
#   MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_OUTPUT - Set before including this file
#                                                  to control the returned URI.
#                                                  Defaults to mock URL if not set.
#
# Usage:
#   SET(MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_OUTPUT "https://example.com/pkg.zip" CACHE INTERNAL "")
#   INCLUDE("mock/CMLIB_STORAGE.cmake")
#

SET(MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_CALLED FALSE
    CACHE INTERNAL
    "TRUE if CMLIB_STORAGE_TEMPLATE_INSTANCE was called"
)
IF(NOT DEFINED MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_OUTPUT)
    SET(MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_OUTPUT ""
        CACHE INTERNAL
        "URI to return from mock; uses default if empty"
    )
ENDIF()
SET(MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_TEMPLATE_VAR ""
    CACHE INTERNAL
    "Captured template variable name argument"
)
SET(MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_ARCHIVE_NAME ""
    CACHE INTERNAL
    "Captured ARCHIVE_NAME argument"
)

##
# Mock implementation of CMLIB_STORAGE_TEMPLATE_INSTANCE
#
# Returns MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_OUTPUT or a default mock URL.
#
FUNCTION(CMLIB_STORAGE_TEMPLATE_INSTANCE output_var template_var_name)
    SET_PROPERTY(CACHE MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_CALLED PROPERTY VALUE TRUE)
    SET_PROPERTY(CACHE MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_TEMPLATE_VAR PROPERTY VALUE "${template_var_name}")
    CMLIB_PARSE_ARGUMENTS(
        ONE_VALUE
            REVISION
            GIT_PATH
            ARCHIVE_NAME
            PACKAGE_GROUP_NAME
        P_ARGN
            ${ARGN}
    )
    IF(__ARCHIVE_NAME)
        SET_PROPERTY(CACHE MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_ARCHIVE_NAME PROPERTY VALUE "${__ARCHIVE_NAME}")
    ENDIF()
    SET(result "https://mock.example.com/mock_expanded_uri")
    IF(NOT "${MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_OUTPUT}" STREQUAL "")
        SET(result "${MOCK_CMLIB_STORAGE_TEMPLATE_INSTANCE_OUTPUT}")
    ENDIF()
    SET(${output_var} "${result}" PARENT_SCOPE)
ENDFUNCTION()

