
FIND_PACKAGE(CMLIB REQUIRED COMPONENTS CMCONF)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/helpers/BA_PACKAGE_PREREQ.cmake")

SET(BA_PACKAGE_CMCONF_USE TRUE
    CACHE BOOL
    "Switch on for CMCONF use; off for testing purposes. Do not alter this setting unless you know what you are doing."
)
IF(BA_PACKAGE_CMCONF_USE)
    BA_PACKAGE_PREREQ_CMCONF_INIT(template revision git_archive_path_template)
ENDIF()

IF(BA_PACKAGE_HTTP_HEADER)
    IF(CMLIB_FILE_DOWNLOAD_HTTP_HEADER)
        MESSAGE(WARNING "BA_PACKAGE_HTTP_HEADER is defined but CMLIB_FILE_DOWNLOAD_HTTP_HEADER is already set. Using BA_PACKAGE_HTTP_HEADER.")
    ENDIF()
    SET(CMLIB_FILE_DOWNLOAD_HTTP_HEADER "${BA_PACKAGE_HTTP_HEADER}"
        CACHE STRING
        "HTTP header set by Package Tracker to access the private repository"
        FORCE
    )
ENDIF()



INCLUDE("${CMAKE_CURRENT_LIST_DIR}/BA_PACKAGE_VARS.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/BA_PACKAGE.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/BA_PACKAGE_DEPS.cmake")

BA_PACKAGE_VARS_SET(REVISION          "${revision}")
BA_PACKAGE_VARS_SET(URI_TEMPLATE      "${template}")
BA_PACKAGE_VARS_SET(GIT_PATH_TEMPLATE "${git_archive_path_template}")
