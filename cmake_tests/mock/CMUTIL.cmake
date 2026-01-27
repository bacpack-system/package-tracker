##
#
# Mock CMUTIL module for testing BA_PACKAGE_LIBRARY platform string construction
#
# This mock replaces CMUTIL_PLATFORM_STRING_CONSTRUCT to return a deterministic
# platform string without querying the actual system. Allows tests to run
# consistently across different platforms.
#
# Captured variables (CACHE INTERNAL):
#   MOCK_CMUTIL_PLATFORM_STRING_CONSTRUCT_CALLED - TRUE if function was called
#
# Configuration:
#   MOCK_CMUTIL_PLATFORM_STRING - Set before including this file to override
#                                  the default platform string construction.
#                                  If not set, constructs from input arguments.
#
# Usage:
#   SET(MOCK_CMUTIL_PLATFORM_STRING "x86_64_ubuntu_22.04" CACHE INTERNAL "")
#   INCLUDE("mock/CMUTIL.cmake")
#

SET(MOCK_CMUTIL_PLATFORM_STRING_CONSTRUCT_CALLED FALSE
    CACHE INTERNAL
    "TRUE if CMUTIL_PLATFORM_STRING_CONSTRUCT was called"
)
SET(MOCK_CMUTIL_PLATFORM_STRING ""
    CACHE INTERNAL
    "Platform string to return; uses constructed value if empty"
)

##
# Mock implementation of CMUTIL_PLATFORM_STRING_CONSTRUCT
#
# Returns MOCK_CMUTIL_PLATFORM_STRING or constructs from MACHINE_DISTRO_NAME_ID_DISTRO_VERSION_ID.
#
FUNCTION(CMUTIL_PLATFORM_STRING_CONSTRUCT)
    SET_PROPERTY(CACHE MOCK_CMUTIL_PLATFORM_STRING_CONSTRUCT_CALLED PROPERTY VALUE TRUE)
    CMLIB_PARSE_ARGUMENTS(
        ONE_VALUE
            MACHINE
            DISTRO_NAME_ID
            DISTRO_VERSION_ID
            OUTPUT_VAR
        P_ARGN
            ${ARGN}
    )
    SET(result "${__MACHINE}_${__DISTRO_NAME_ID}_${__DISTRO_VERSION_ID}")
    IF(MOCK_CMUTIL_PLATFORM_STRING)
        SET(result "${MOCK_CMUTIL_PLATFORM_STRING}")
    ENDIF()
    SET(${__OUTPUT_VAR} "${result}" PARENT_SCOPE)
ENDFUNCTION()

