##
#
#
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.21)

IF(NOT CMAKE_SCRIPT_MODE_FILE)
    MESSAGE(FATAL_ERROR "Please, run this in CMake script mode!")
ENDIF()

SET(INVALID_VAR_TEST FALSE
    CACHE BOOL
    "Switch on invalid var test"
)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../BA_PACKAGE_VARS.cmake")

##
#
# It checks whether the Set/Get functions set the proper variable
#
# <function> (
# )
#
FUNCTION(SETVAR_TEST)
    BA_PACKAGE_VARS_SET(REVISION "main")
    IF(NOT BA_PACKAGE_VARS__REVISION STREQUAL "main")
        MESSAGE(FATAL_ERROR "Variable set does not work! Case 1")
    ENDIF()
    BA_PACKAGE_VARS_SET(REVISION "testvalue")
    IF(NOT BA_PACKAGE_VARS__REVISION STREQUAL "testvalue")
        MESSAGE(FATAL_ERROR "Variable set does not work! Case 2")
    ENDIF()
ENDFUNCTION()

##
#
# It tries to set an invalid variable and emit an error
#
# <function>(
# )
#
FUNCTION(SETVAR_TEST_FAIL)
    # Emit a fatal error
    BA_PACKAGE_VARS_SET(REVISIONBADVAR "main")
ENDFUNCTION()



IF(INVALID_VAR_TEST)
    SETVAR_TEST_FAIL()
ELSE()
    SETVAR_TEST()
ENDIF()
