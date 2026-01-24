##
#
# Mock CMCONF module for testing BA_PACKAGE_PREREQ_CMCONF_INIT
#
# This mock provides CMCONF_GET function that returns pre-configured test values.
# Test values are set via TEST_CMCONF_<var_name> before using CMCONF_GET
#

FUNCTION(CMCONF_GET var_name)
    IF(NOT DEFINED TEST_CMCONF_${var_name})
        MESSAGE(FATAL_ERROR "Mock CMCONF_GET: TEST_CMCONF_${var_name} is not defined")
    ENDIF()
    SET(${var_name} "${TEST_CMCONF_${var_name}}" PARENT_SCOPE)
ENDFUNCTION()

