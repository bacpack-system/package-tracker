##
#
# BringAuto Package script.
#
# Enable us to download and track dependencies built by BringAuto Packager.
#

FIND_PACKAGE(CMLIB COMPONENTS CMUTIL CMDEF)



##
#
# Download, cache and populate library development package
#
# CACHE_ONLY - if specified no download is performed. The package
# must be cached by a previous call to BA_PACKAGE_LIBRARY() without CACHE_ONLY switch.
#
# NO_DEBUG - use release, not debug version of the package (can be used if release and debug
# variant are equal)
#
# OUTPUT_PATH_VAR - name of the variable where the absolute path of the package root will be stored. 
#
# Wrapper arounf BA_PACKAGE
# - adds package path to CMAKE_PREFIX_PATH
# - propagates output variables
# - manage prefixes and suffixes
#
# <function>(
#   <package_name>
#   <version_tag>
#   [OUTPUT_PATH_VAR <output_path_var_name>]
#   [CACHE_ONLY {ON|OFF}]
#   [NO_DEBUG {ON|OFF}]
# )
#
FUNCTION(BA_PACKAGE_LIBRARY package_name version_tag)
    CMLIB_PARSE_ARGUMENTS(
        ONE_VALUE
            OUTPUT_PATH_VAR
        OPTIONS
            CACHE_ONLY
            NO_DEBUG
        P_ARGN
            ${ARGN}
    )

    SET(suffix)
    IF("${CMAKE_BUILD_TYPE}" STREQUAL "Debug" AND (NOT __NO_DEBUG))
        SET(suffix "d")
    ENDIF()

    BA_PACKAGE(${package_name} ${version_tag} "lib" "${suffix}-dev" output_var
        CACHE_ONLY           ${__CACHE_ONLY}
        NO_DEBUG             ${__NO_DEBUG}
    )

    SET(_t ${CMAKE_PREFIX_PATH})
    LIST(APPEND _t "${output_var}")
    SET(CMAKE_PREFIX_PATH ${_t} PARENT_SCOPE)

    IF(__OUTPUT_PATH_VAR)
        SET(${__OUTPUT_PATH_VAR} "${output_var}" PARENT_SCOPE)
    ENDIF()

ENDFUNCTION()



##
#
# Download, cache and populate Executable package.
#
# CACHE_ONLY - if specified no download is performed. The package
# must be cached by a previous call to BA_PACKAGE_EXECUTABLE() without CACHE_ONLY switch.
#
# NO_DEBUG - use release, not debug version of the package (can be used if release and debug
# variant are equal)
#
# OUTPUT_PATH_VAR - name of the variable where the absolute path of the package root will be stored. 
#
# Wrapper arounf BA_PACKAGE
# - adds package path to CMAKE_PREFIX_PATH
# - propagates output variables
# - manage prefixes and suffixes
#
# <function>(
#   <package_name>
#   <version_tag>
#   [OUTPUT_PATH_VAR <output_path_var_name>]
#   [CACHE_ONLY {ON|OFF}]
#   [NO_DEBUG {ON|OFF}]
# )
#
FUNCTION(BA_PACKAGE_EXECUTABLE package_name version_tag)
    CMLIB_PARSE_ARGUMENTS(
        ONE_VALUE
            OUTPUT_PATH_VAR
        OPTIONS
            CACHE_ONLY
            NO_DEBUG
        P_ARGN
            ${ARGN}
    )

    SET(suffix)
    IF("${CMAKE_BUILD_TYPE}" STREQUAL "Debug" AND (NOT __NO_DEBUG))
        SET(suffix "d")
    ENDIF()

    BA_PACKAGE(${package_name} ${version_tag} "" "${suffix}" output_var
        CACHE_ONLY           ${__CACHE_ONLY}
        NO_DEBUG             ${__NO_DEBUG}
    )

    SET(_t ${CMAKE_PREFIX_PATH})
    LIST(APPEND _t "${output_var}")
    SET(CMAKE_PREFIX_PATH ${_t} PARENT_SCOPE)

    IF(__OUTPUT_PATH_VAR)
        SET(${__OUTPUT_PATH_VAR} "${output_var}" PARENT_SCOPE)
    ENDIF()

ENDFUNCTION()



##
#
# Download, cache and populate package represented by 'package_name'
# and concretized by 'prefix' and 'suffix'.
#
# <function>(
#   <package_name>
#   <version_tag>
#   <prefix> <suffix> <output_var>
#   [CACHE_ONLY {ON|OFF}]
#   [NO_DEBUG {ON|OFF}]
# )
#
FUNCTION(BA_PACKAGE package_name version_tag prefix suffix output_var)
    CMLIB_PARSE_ARGUMENTS(
        OPTIONS
            CACHE_ONLY
            NO_DEBUG
        P_ARGN
            ${ARGN}
    )

    SET(machine               "${CMDEF_ARCHITECTURE}")
    SET(package_name_expanded "${prefix}${package_name}${suffix}")

    CMUTIL_PLATFORM_STRING_CONSTRUCT(
        MACHINE ${machine}
        DISTRO_NAME_ID "${CMDEF_DISTRO_ID}"
        DISTRO_VERSION_ID "${CMDEF_DISTRO_VERSION_ID}"
        OUTPUT_VAR platform_string
    )
    SET(package_string "${package_name_expanded}_${version_tag}_${platform_string}.zip")

    BA_PACKAGE_VARS_GET(REVISION revision_var)
    SET(git_path "${CMDEF_DISTRO_ID}/${CMDEF_DISTRO_VERSION_ID}/${machine}")
    BA_PACKAGE_VARS_GET(ESCAPE_TEMPLATE_ARGS escape_template_args)
    IF(escape_template_args)
        _BA_PACKAGE_URL_ENCODE("${revision_var}"   revision_var)
        _BA_PACKAGE_URL_ENCODE("${git_path}"       git_path)
        _BA_PACKAGE_URL_ENCODE("${package_string}" package_string)
        _BA_PACKAGE_URL_ENCODE("${package_name}"   package_name)
    ENDIF()

    SET(revision_arg)
    IF(revision_var)
        SET(revision_arg REVISION "${revision_var}")
    ENDIF()

    BA_PACKAGE_VARS_GET(URI_TEMPLATE template_var)
    CMLIB_STORAGE_TEMPLATE_INSTANCE(remote_file template_var
        ${revision_arg}
        GIT_PATH "${git_path}"
        ARCHIVE_NAME "${package_string}"
        PACKAGE_GROUP_NAME "${package_name}"
    )

    SET(git_archive_path_arg)
    SET(git_revision_arg)
    BA_PACKAGE_VARS_GET(GIT_PATH_TEMPLATE git_path_template_var)
    IF(git_path_template_var)
        CMLIB_STORAGE_TEMPLATE_INSTANCE(git_archive_path git_path_template_var
            ${revision_arg}
            GIT_PATH "${git_path}"
            ARCHIVE_NAME "${package_string}"
            PACKAGE_GROUP_NAME "${package_name}"
        )
        SET(git_revision_arg     GIT_REVISION "${revision_var}")
        SET(git_archive_path_arg GIT_PATH "${git_archive_path}")
    ENDIF()

    STRING(TOUPPER "${package_name}" package_name_upper_orig)
    STRING(REGEX REPLACE "[^A-Z0-9]" "" package_name_upper "${package_name_upper_orig}")
    IF(NOT package_name_upper)
        MESSAGE(FATAL_ERROR "Invalid package name: ${package_name}")
    ENDIF()

    # Not sure if this is usefull? In production it feels weird.
    # The only reason is to not have accidental collisions.... 
    #IF(NOT (package_name_upper STREQUAL package_name_upper_orig))
    #    MESSAGE(WARNING "Package name ${package_name} contains invalid characters. It was normalized to form a proper CMLIB cache keyword: ${package_name} --> ${package_name_upper}")
    #ENDIF()

    SET(keywords BACPACK ${package_name_upper})

    IF(NOT __NO_DEBUG)
        STRING(TOUPPER "${CMAKE_BUILD_TYPE}" build_type_upper)
        LIST(APPEND keywords ${build_type_upper})
    ENDIF()

    SET(cache_path)
    IF(__CACHE_ONLY)
        CMLIB_CACHE_GET(
            KEYWORDS ${keywords}
            CACHE_PATH_VAR cache_path
            TRY_REGENERATE ON
        )
        IF(NOT cache_path)
            MESSAGE(FATAL_ERROR "Package not found: ${package_string}")
        ENDIF()
    ELSE()
        _BA_PACKAGE_MESSAGE(REGISTER ${package_name})
        CMLIB_DEPENDENCY(
            KEYWORDS ${keywords}
            TYPE ARCHIVE
            ARCHIVE_TYPE ZIP
            URI "${remote_file}"
            ${git_revision_arg}
            ${git_archive_path_arg}
            OUTPUT_PATH_VAR cache_path
        )
    ENDIF()

    SET(${output_var} ${cache_path} PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# Percent-encode characters that are not allowed in URI components.
#
# <function>(
#   <input> <output_var>
# )
#
FUNCTION(_BA_PACKAGE_URL_ENCODE input output)
    SET(result "${input}")
    STRING(REPLACE "%" "%25" result "${result}")
    STRING(REPLACE " " "%20" result "${result}")
    STRING(REPLACE "!" "%21" result "${result}")
    STRING(REPLACE "#" "%23" result "${result}")
    STRING(REPLACE "$" "%24" result "${result}")
    STRING(REPLACE "&" "%26" result "${result}")
    STRING(REPLACE "'" "%27" result "${result}")
    STRING(REPLACE "(" "%28" result "${result}")
    STRING(REPLACE ")" "%29" result "${result}")
    STRING(REPLACE "*" "%2A" result "${result}")
    STRING(REPLACE "+" "%2B" result "${result}")
    STRING(REPLACE "," "%2C" result "${result}")
    STRING(REPLACE "/" "%2F" result "${result}")
    STRING(REPLACE ":" "%3A" result "${result}")
    STRING(REPLACE ";" "%3B" result "${result}")
    STRING(REPLACE "=" "%3D" result "${result}")
    STRING(REPLACE "?" "%3F" result "${result}")
    STRING(REPLACE "@" "%40" result "${result}")
    SET(${output} "${result}" PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# Print preformatted message
#
# <function>(
#   <action> <message>
# )
#
FUNCTION(_BA_PACKAGE_MESSAGE action message)
    SET(list_of_available_actions "REGISTER")
    LIST(FIND list_of_available_actions ${action} item)
    IF(item EQUAL -1)
        MESSAGE(FATAL_ERROR "BA_PACKAGE: Cannot print unknown action ${action}")
    ENDIF()
    MESSAGE(STATUS "BA_PACKAGE [${action}]: ${message}")
ENDFUNCTION()
