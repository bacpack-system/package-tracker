##
#
# BringAuto Package prerequisites helpers
#
# Utilities used by Package Tracker to initialize storage and URI templates.
#

##
#
# Validate local Package Repository path
#
# <function>(
#   <local_repository_path> // absolute path to an existing directory
# )
#
FUNCTION(BA_PACKAGE_PREREQ_LOCAL_PATH_CHECK local_repository_path)
    IF(NOT IS_ABSOLUTE "${local_repository_path}")
        MESSAGE(FATAL_ERROR "Local repository path variable is not absolute path: '${local_repository_path}'")
    ENDIF()
    IF(NOT IS_DIRECTORY "${local_repository_path}")
        MESSAGE(FATAL_ERROR "Local repository path variable is not a directory: '${local_repository_path}'")
    ENDIF()
ENDFUNCTION()



##
#
# Initialize URI template and revision from Global Config (CMCONF)
#
# Reads BA_PACKAGE_* settings and selects either local repository file:// template
# or remote URI template with revision. If BA_PACKAGE_LOCAL_PATH env var is set,
# it takes precedence.
#
# <function>(
#   <template_output_var>  // variable name to receive the template (parent scope)
#   <revision_output_var>  // variable name to receive the revision (parent scope)
# )
#
FUNCTION(BA_PACKAGE_PREREQ_CMCONF_INIT template_output_var revision_output_var git_archive_path_template_output_var http_header_output_var template_args_uri_escape)
    #
    # Let's get variables to ensure they are defined
    # By a Global Config for their appropriate use...
    #
    CMCONF_GET(BA_PACKAGE_LOCAL_USE)
    IF(BA_PACKAGE_LOCAL_USE)
        CMCONF_GET(BA_PACKAGE_LOCAL_PATH)
    ELSE()
        CMCONF_GET(BA_PACKAGE_HTTP_HEADER)
        CMCONF_GET(BA_PACKAGE_URI_REVISION)
        CMCONF_GET(BA_PACKAGE_GIT_ARCHIVE_PATH_TEMPLATE)
        CMCONF_GET(BA_PACKAGE_URI_TEMPLATE_REMOTE)
    ENDIF()

    SET(template)
    SET(revision)
    SET(git_archive_path)
    SET(http_header)
    SET(template_args_uri_escape)
    IF(DEFINED ENV{BA_PACKAGE_LOCAL_PATH})
        IF(BA_PACKAGE_LOCAL_USE)
            MESSAGE(WARNING "BA_PACKAGE_LOCAL_PATH ENV variable is defined and BA_PACKAGE_LOCAL_USE is ON. Using BA_PACKAGE_LOCAL_PATH ENV variable to set as Repository path")
        ENDIF()
        BA_PACKAGE_PREREQ_LOCAL_PATH_CHECK("$ENV{BA_PACKAGE_LOCAL_PATH}")
        SET(template "file://$ENV{BA_PACKAGE_LOCAL_PATH}/package/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>")
    ELSE()
        IF(BA_PACKAGE_LOCAL_USE)
            BA_PACKAGE_PREREQ_LOCAL_PATH_CHECK("${BA_PACKAGE_LOCAL_PATH}")
            SET(template "file://${BA_PACKAGE_LOCAL_PATH}/package/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>")
        ELSE()
            SET(template "${BA_PACKAGE_URI_TEMPLATE_REMOTE}")
            SET(revision "${BA_PACKAGE_URI_REVISION}")
            SET(git_archive_path "${BA_PACKAGE_GIT_ARCHIVE_PATH_TEMPLATE}")
            SET(http_header "${BA_PACKAGE_HTTP_HEADER}")
            SET(template_args_uri_escape "${BA_PACKAGE_TEMPLATE_ARGS_URI_ESCAPE}")
        ENDIF()
    ENDIF()

    # unreachable, but for clarity...
    IF(revision AND (BA_PACKAGE_LOCAL_USE OR DEFINED ENV{BA_PACKAGE_LOCAL_PATH}))
        MESSAGE(WARNING "Revision is defined but local repository is used.")
    ENDIF()
    
    IF(BA_PACKAGE_GIT_ARCHIVE_PATH_TEMPLATE AND BA_PACKAGE_HTTP_HEADER)
        MESSAGE(WARNING "BA_PACKAGE_HTTP_HEADER is defined together with BA_PACKAGE_GIT_ARCHIVE_PATH_TEMPLATE. ARCHIVE_PATH_TEMPLATE implies the URI type is GIT but HTTP_HEADERS are used only for raw HTTP Downloads!")
    ENDIF()

    SET(${template_output_var} "${template}" PARENT_SCOPE)
    SET(${revision_output_var} "${revision}" PARENT_SCOPE)
    SET(${git_archive_path_template_output_var} "${git_archive_path}" PARENT_SCOPE)
    SET(${http_header_output_var} "${http_header}" PARENT_SCOPE)
    SET(${template_args_uri_escape} "${template_args_uri_escape}" PARENT_SCOPE)
ENDFUNCTION()