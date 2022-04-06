##
#
# BringAuto Package script.
#
# Enable us to download and track dependencies build by BringAuto Packager.
#

FIND_PACKAGE(CMLIB COMPONENTS CMUTIL CMDEF)



##
#
# Download, cache and populate library development package
#
# CACHE_ONLY - if specified no download is performed. The package
# must be cached by previous of BA_PACKAGE_LIBRARY() without CACHE_ONLY switch.
#
# NO_DEBUG - use release, not debug version of the package (can be used if release and debug
# variant are equal)
#
# PLATFORM_STRING_MODE - mode of platform string construction (platform string represents
# id of the target platfrom for which we build...).
#   - "aby_machine" - inform packager we use package that is not bound to the target architecture.
#
# OUTPUT_PATH_VAR - name of the variable where the absolute path of the package root will be stored. 
#
# <function>(
#   <package_name>
#   <version_tag>
#   [OUTPUT_PATH_VAR <output_path_var_name>]
#   [PLATFORM_STRING_MODE {"any_machine"}]
#   [CACHE_ONLY {ON|OFF}]
#   [NO_DEBUG {ON|OFF}]
# )
#
FUNCTION(BA_PACKAGE_LIBRARY package_name version_tag)
    CMLIB_PARSE_ARGUMENTS(
        ONE_VALUE
            PLATFORM_STRING_MODE
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

    _BRINGAUTO_PACKAGE(${package_name} ${version_tag} "lib" "${suffix}-dev" output_var
        PLATFORM_STRING_MODE ${__PLATFORM_STRING_MODE}
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
# Download, cache and populate Executable package
#
# <function>(
#   <package_name>
#   <version_tag>
#   [OUTPUT_PATH_VAR <output_path_var_name>]
#   [PLATFORM_STRING_MODE {"any_machine"}]
#   [CACHE_ONLY {ON|OFF}]
#   [NO_DEBUG {ON|OFF}]
# )
#
FUNCTION(BA_PACKAGE_EXECUTABLE package_name varsion_tag)
    CMLIB_PARSE_ARGUMENTS(
        ONE_VALUE
            PLATFORM_STRING_MODE
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

    _BRINGAUTO_PACKAGE(${package_name} ${version_tag} "" "${suffix}" output_var
        PLATFORM_STRING_MODE ${__PLATFORM_STRING_MODE}
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



## Helper
#
# Download, cache and populate package represented by 'package_name'
# and concretized by 'prefix' and 'suffix'.
#
# <function>(
#   <package_name>
#   <version_tag>
#   [PLATFORM_STRING_MODE {"any_machine"}]
#   [CACHE_ONLY {ON|OFF}]
#   [NO_DEBUG {ON|OFF}]
# )
#
FUNCTION(_BRINGAUTO_PACKAGE package_name version_tag prefix suffix output_var)
    CMLIB_PARSE_ARGUMENTS(
        ONE_VALUE
            PLATFORM_STRING_MODE
        OPTIONS
            CACHE_ONLY
            NO_DEBUG
        P_ARGN
            ${ARGN}
    )

    STRING(TOLOWER "${__PLATFORM_STRING_MODE}" plat_string_mode_lower)

    SET(machine)
    IF("${plat_string_mode_lower}" STREQUAL "any_machine")
        SET(machine "any")
    ELSE()
        SET(machine "${CMDEF_ARCHITECTURE}")
    ENDIF()

    SET(package_name_expanded "${prefix}${package_name}${suffix}")

    CMUTIL_PLATFORM_STRING_CONSTRUCT(
        MACHINE ${machine}
        DISTRO_NAME_ID "${CMDEF_DISTRO_ID}"
        DISTRO_VERSION_ID "${CMDEF_DISTRO_VERSION_ID}"
        OUTPUT_VAR platform_string
    )
    SET(package_string "${package_name_expanded}_${version_tag}_${platform_string}.zip")

    SET(git_path "${CMDEF_DISTRO_ID}/${CMDEF_DISTRO_VERSION_ID}/${machine}")
    CMLIB_STORAGE_TEMPLATE_INSTANCE( remote_file BRINGAUTO_REPOSITORY_URL_TEMPLATE
        REVISION "master"
        GIT_PATH "${git_path}"
        PACKAGE_NAME "${package_string}"
        ARCHIVE_NAME "${package_name}"
    )

    STRING(TOUPPER "${package_name}" package_name_upper)
    STRING(REGEX REPLACE "[^A-Z]" "" package_name_upper  "${package_name_upper}")
    IF(NOT package_name_upper)
        MESSAGE(FATAL_ERROR "Invalid package name: ${package_name}")
    ENDIF()
    SET(keywords BAPACK ${package_name_upper})

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
            MESSAGE(FATAL_ERROR "Package does not found: ${package_string}")
        ENDIF()
    ELSE()
        _BA_PACKAGE_MESSAGE(DOWNLOAD ${package_name})
        CMLIB_DEPENDENCY(
            KEYWORDS ${keywords}
            TYPE ARCHIVE
            URI "${remote_file}"
            OUTPUT_PATH_VAR cache_path
        )
    ENDIF()

    SET(${output_var} ${cache_path} PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# Print preformetted message
#
# <function>(
#   <action> <message>
# )
#
FUNCTION(_BA_PACKAGE_MESSAGE action message)
    SET(list_of_available_actions "DOWNLOAD")
    LIST(FIND list_of_available_actions ${action} item)
    IF(item EQUAL -1)
        MESSAGE(FATAL_ERROR "BA_PACKAGE: Cannot print unknown action ${action}")
    ENDIF()
    MESSAGE(STATUS "BA PACKAGE [${action}]: ${message}")
ENDFUNCTION()