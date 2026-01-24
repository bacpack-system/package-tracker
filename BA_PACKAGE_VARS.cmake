##
#
# BringAuto Package Variables
#
# Variables and Setter/Getter functions.
# - Every variable has a name (var_name).
# - Every variable accessed by Setter/Getter should
#   be stored as INTERNAL cache variable.
# - Every variable is stored as a CMake cache variable with name BA_PACKAGE_VARS__<var_name>.
#   Double _ is chosen to avoid defining reserved variable names SET and GET.
# - Every variable shall be set/get by a SetterGetter function.
#
# Mechanism of Setter/Getter was chosen in order to simplify
# future maintenance and "configuration" (in backward compatibility manner)
#
# Example of REVISION
#   BA_PACKAGE_VARS_SET(REVISION "main")
#

SET(BA_PACKAGE_VARS__REVISION "master"
    CACHE INTERNAL
    "Package Repository revision to use"
)

SET(BA_PACKAGE_VARS__URI_TEMPLATE "NonExistentPath"
    CACHE INTERNAL
    "Storage URI template used to construct the package download URI"
)

SET(BA_PACKAGE_VARS__GIT_PATH_TEMPLATE "NonExistentPath"
    CACHE INTERNAL
    "Git path template to use. If non empty the URI_TEMPALTE represents remote Git repository. Takes same template params as URI_TEMPLATE."
)



##
#
# It sets the variable value.
#
# <function>(
#   var_name // uppercase variable name
#   var_value // variable value to set
# )
#
FUNCTION(BA_PACKAGE_VARS_SET var_name var_value)
    IF(NOT var_name)
        MESSAGE(FATAL_ERROR "Package tracker variable invalid set. Variable name not specified!")
    ENDIF()
    SET(cache_var_name "BA_PACKAGE_VARS__${var_name}")
    IF(NOT DEFINED ${cache_var_name})
        MESSAGE(FATAL_ERROR "Package variable invalid set. Trying to set non-defined BA_PACKAGE variable '${var_name}'")
    ENDIF()
    SET_PROPERTY(CACHE ${cache_var_name} PROPERTY VALUE "${var_value}")
ENDFUNCTION()



##
#
# It gets the variable value.
#
# <function>(
#   var_name        // uppercase variable name
#   output_var_name // variable name to receive the value
# )
#
FUNCTION(BA_PACKAGE_VARS_GET var_name output_var_name)
    IF(NOT var_name)
        MESSAGE(FATAL_ERROR "Package tracker variable invalid get. Variable name not specified!")
    ENDIF()
    SET(cache_var_name "BA_PACKAGE_VARS__${var_name}")
    IF(NOT DEFINED ${cache_var_name})
        MESSAGE(FATAL_ERROR "Package variable invalid get. Trying to set non-defined BA_PACKAGE variable '${var_name}'")
    ENDIF()
    IF(NOT output_var_name)
        MESSAGE(FATAL_ERROR "Package tracker variable invalid get. Output var name is not defined!")
    ENDIF()
    SET(${output_var_name} ${${cache_var_name}} PARENT_SCOPE)
ENDFUNCTION()
