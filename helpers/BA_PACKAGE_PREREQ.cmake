##
#
#
#


##
#
#
FUNCTION(BA_PACKAGE_PREREQ_LOCAL_PATH_CHECK local_repository_path)
    IF(NOT IS_ABSOLUTE "${local_repository_path}")
        MESSAGE(FATAL_ERROR "Local repository path variable is not absolute path: '${local_repository_path}'")
    ENDIF()
    IF(NOT IS_DIRECTORY "${local_repository_path}")
        MESSAGE(FATAL_ERROR "Local repository path variable is not a directory: '${local_repository_path}'")
    ENDIF()
ENDFUNCTION()
