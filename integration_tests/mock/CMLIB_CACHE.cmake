##
#
# Mock CMLIB_CACHE module for testing BA_PACKAGE_LIBRARY CACHE_ONLY mode
#
# This mock captures arguments passed to CMLIB_CACHE_GET and returns a
# configurable path. Used to test BA_PACKAGE_LIBRARY's CACHE_ONLY behavior
# without accessing the real CMLIB cache.
#
# Captured variables (CACHE INTERNAL):
#   MOCK_CMLIB_CACHE_GET_CALLED    - TRUE if function was called
#   MOCK_CMLIB_CACHE_GET_KEYWORDS  - List of KEYWORDS passed
#
# Configuration:
#   MOCK_CMLIB_CACHE_GET_RETURN_PATH - Set before including this file to control
#                                      the return value. Empty string simulates
#                                      cache miss (package not found).
#
# Usage:
#   SET(MOCK_CMLIB_CACHE_GET_RETURN_PATH "/mock/cached/path" CACHE INTERNAL "")
#   INCLUDE("mock/CMLIB_CACHE.cmake")
#   BA_PACKAGE_LIBRARY(pkg v1.0.0 CACHE_ONLY ON)
#   # Verify MOCK_CMLIB_CACHE_GET_CALLED is TRUE
#

SET(MOCK_CMLIB_CACHE_GET_CALLED FALSE
    CACHE INTERNAL
    "TRUE if CMLIB_CACHE_GET was called"
)
SET(MOCK_CMLIB_CACHE_GET_KEYWORDS ""
    CACHE INTERNAL
    "Captured KEYWORDS argument list"
)
IF(NOT DEFINED MOCK_CMLIB_CACHE_GET_RETURN_PATH)
    SET(MOCK_CMLIB_CACHE_GET_RETURN_PATH ""
        CACHE INTERNAL
        "Path to return from mock; empty simulates cache miss"
    )
ENDIF()

##
# Mock implementation of CMLIB_CACHE_GET
#
# Captures KEYWORDS and returns MOCK_CMLIB_CACHE_GET_RETURN_PATH via CACHE_PATH_VAR.
#
FUNCTION(CMLIB_CACHE_GET)
    SET_PROPERTY(CACHE MOCK_CMLIB_CACHE_GET_CALLED PROPERTY VALUE TRUE)
    CMLIB_PARSE_ARGUMENTS(
        MULTI_VALUE
            KEYWORDS
        ONE_VALUE
            CACHE_PATH_VAR
        OPTIONS
            TRY_REGENERATE
        P_ARGN
            ${ARGN}
    )
    SET_PROPERTY(CACHE MOCK_CMLIB_CACHE_GET_KEYWORDS PROPERTY VALUE "${__KEYWORDS}")
    IF(__CACHE_PATH_VAR)
        SET(${__CACHE_PATH_VAR} "${MOCK_CMLIB_CACHE_GET_RETURN_PATH}" PARENT_SCOPE)
    ENDIF()
ENDFUNCTION()

