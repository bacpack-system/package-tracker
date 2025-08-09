##
#
# BringAuto Package Dependencies scripts.
#
# Pack dependencies of the given target as a part
# of the package.
#

FIND_PACKAGE(CMLIB COMPONENTS CMDEF REQUIRED)



##
#
# It sets the INSTALL_RUNPATH of the target to a
# library directory specified by CMDEF_LIBRARY_INSTALL_DIR.
#
# It is expected the 'target' is installed and maintained by CMDEF_INSTALL macro.
#
# <function> (
#	<cmake_target>
# )
#
FUNCTION(BA_PACKAGE_DEPS_SET_TARGET_RPATH target)
	IF(NOT TARGET ${target})
		MESSAGE(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: cannot repair RUNPATH for non existent target '${target}'")
	ENDIF()

	CMDEF_INSTALL_USED_FOR(TARGET ${target} OUTPUT_VAR cmdef_install_used)
	IF(NOT cmdef_install_used)
		MESSAGE(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: cannot repair RUNPATH for targets not installed by CMDEF_INSTALL")
	ENDIF()

	# we need to compute relative of install library path against target
	# output install path. CMake FILE(RELATIVE_PATH ...) can work only with absolute paths
	SET(absolute_path_prefix "/my/absolute/path/")
	SET(library_path         "${absolute_path_prefix}/${CMDEF_LIBRARY_INSTALL_DIR}")
	SET(target_output_path)

	GET_TARGET_PROPERTY(target_type ${target} TYPE)
	IF("${target_type}" STREQUAL "EXECUTABLE")
		SET(target_output_path "${absolute_path_prefix}/${CMDEF_BINARY_INSTALL_DIR}")
	ELSEIF("${target_type}" STREQUAL "SHARED_LIBRARY")
		SET(target_output_path "${absolute_path_prefix}/${CMDEF_LIBRARY_INSTALL_DIR}")
	ENDIF()

	SET(runpath)
	IF(target_output_path)
		FILE(RELATIVE_PATH runpath "${target_output_path}" "${library_path}")
	ELSE()
		MESSAGE(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: unsupported CMake target type '${target_type}'")
	ENDIF()

	SET_TARGET_PROPERTIES(${target} PROPERTIES INSTALL_RPATH "$ORIGIN/${runpath}")

ENDFUNCTION()


##
#
# Function goes through target link dependencies, gathers all
# imported shared libraries, installs them and repairs RUNPATH for all installed libraries.
#
# The install dir for all dependencies is set from CMDEF_LIBRARY_INSTALL_DIR
#
# <function> (
#   <target> <install_dir>
# )
#
FUNCTION(BA_PACKAGE_DEPS_INSTALL_IMPORTED target)

	CMDEF_INSTALL_USED_FOR(TARGET ${target} OUTPUT_VAR cmdef_install_used)
	IF(NOT cmdef_install_used)
		MESSAGE(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}: cannot install imported targets for target not installed with CMDEF_INSTALL")
	ENDIF()

    _BA_PACKAGE_DEPS_GET_DEPENDENCIES_FILES(${target} filenames)

    LIST(REMOVE_DUPLICATES filenames)
	FOREACH(filename IN LISTS filenames)
		INSTALL(CODE "SET(_ba_package_deps_library     ${filename})")
		INSTALL(CODE "SET(_ba_package_deps_install_dir ${CMDEF_LIBRARY_INSTALL_DIR})")
		INSTALL(CODE [[
			FIND_PROGRAM(patchelf patchelf REQUIRED)
			MESSAGE(STATUS "patchelf update R/RUNPATH: ${_ba_package_deps_install_dir}/${_ba_package_deps_library}")
			SET(destdir "$ENV{DESTDIR}")
			SET(working_directory)
			IF(destdir)
				SET(working_directory "${destdir}/${CMAKE_INSTALL_PREFIX}")
			ELSE()
				SET(working_directory "${CMAKE_INSTALL_PREFIX}")
			ENDIF()
			EXECUTE_PROCESS(
				COMMAND           ${patchelf} --set-rpath $ORIGIN ${_ba_package_deps_install_dir}/${_ba_package_deps_library}
				RESULT_VARIABLE    result
				WORKING_DIRECTORY "${working_directory}"
			)
			IF(NOT result EQUAL 0)
				MESSAGE(FATAL_ERROR "Cannot update R/RUNPATH for ${install_dir}/${library}")
			ENDIF()
		]])
	ENDFOREACH()

ENDFUNCTION()

MACRO(BA_PACKAGE_DEPS_IMPORTED target)
	BA_PACKAGE_DEPS_INSTALL_IMPORTED(${target})
ENDMACRO()





## Helper
#
# Function goes through all runtime link dependencies and installs them.
# The install dir for all dependencies is set from CMDEF_LIBRARY_INSTALL_DIR
#
# [Details]
# Function goes through all libraries mentioned in 'target' properties
#   - LINK_LIBRARIES
#   - INTERFACE_LINK_LIBRARIES
#
# Let L be a library taken from one of the properties above.
#
# If L is CMake target (IF(TARGET L) pass as true) and L TYPE is SHARED_LIBRARY then
# INSTALL(IMPORTED_RUNTIME_ARTIFACTS ...) is used to install L.
#
# If L TYPE is UNKNOWN_LIBRARY
# - then take 'filepath' from IMPORTED_LOCATION_{DEBUG|RELEASE} (depending on build type)
# - then take 'filename' by GET_FILENAME_COMPONENT(filename "${filepath} NAME")
# - then check if the 'filename' represents shared library by matching against regex IS_SHARED = "^([^.]+).so[.0-9]*$".
# Let FILENAME is a string obtained from the only group from the regex IS_SHARED
#	- get 'directory' by GET_FILENAME_COMPONENT(DIRECTORY ${filepath} directory)
#   - get 'filenames' from 'directory' with prefix <filename>.so
#   - install all filename into the library directory in target installation dir.
#   - If the set 'filenames' contains at least one symlink, then there must be exactly one F in filenames
#     that is not a symlink --> all symlinks from 'filenames' will point to the file F.
#   - If the set 'filenames' does not contain an element representing a symlink, then all elements in 'filenames'
#     must not be symlinks
#
# [Pitfalls]
# - If there are multiple versions of the same library the function installs them all and can break the app
#   (because of symlinks)
#
# <function> (
#	<target>                          // CMake target for which we want to gather dependencies
#	<filenames_list_not_symlinks_var> // list of filenames (not symlinks) installed by the function
# )
#
FUNCTION(_BA_PACKAGE_DEPS_GET_DEPENDENCIES_FILES target filenames_for_patchelf_var)
    SET(install_dir "${CMDEF_LIBRARY_INSTALL_DIR}")
	GET_TARGET_PROPERTY(link_libraries           ${target} LINK_LIBRARIES)
	GET_TARGET_PROPERTY(interface_link_libraries ${target} INTERFACE_LINK_LIBRARIES)

	SET(link_libraries_list)
	IF(NOT "${link_libraries}" STREQUAL "link_libraries-NOTFOUND")
		LIST(APPEND link_libraries_list ${link_libraries})
	ENDIF()
	IF(NOT "${interface_link_libraries}" STREQUAL "interface_link_libraries-NOTFOUND")
		LIST(APPEND link_libraries_list ${interface_link_libraries})
	ENDIF()

    SET(filenames ${${filenames_for_patchelf_var}})
	FOREACH(library IN LISTS link_libraries_list)
		IF(NOT TARGET ${library})
			CONTINUE()
		ENDIF()

		_BA_PACKAGE_DEPS_GET_IMPORTED_LOCATION(${library} filepath)
		IF(NOT filepath)
        	_BA_PACKAGE_DEPS_GET_DEPENDENCIES_FILES(${library} filenames)
			CONTINUE()
		ENDIF()
		GET_FILENAME_COMPONENT(filename "${filepath}" NAME)
		LIST(FIND filenames "${filename}" filename_already_processed)
		IF(NOT filename_already_processed EQUAL -1)
			CONTINUE()
		ENDIF()

		GET_TARGET_PROPERTY(library_type ${library} TYPE)

		IF("${library_type}" STREQUAL "SHARED_LIBRARY" OR "${library_type}" STREQUAL "UNKNOWN_LIBRARY")
            # We need to install files manually, we cannot use INSTALL_IMPORTED_TARGETS because of symlinks
			STRING(REGEX MATCH "^([^.]+.so)[.0-9]*$" is_shared "${filename}")
			IF(NOT is_shared)
				CONTINUE()
			ENDIF()
			SET(library_name "${CMAKE_MATCH_1}")
			GET_FILENAME_COMPONENT(filepath_directory "${filepath}" DIRECTORY)
			_BA_PACKAGE_DEPS_GET_ALL_SONAME_FILES("${filepath_directory}/${library_name}" filepath_list)
			SET(symlink_filename_list)
			SET(symlink_list)
			SET(filename_list)
			SET(filepath_list_filtered)
            FOREACH(_file IN LISTS filepath_list)
				GET_FILENAME_COMPONENT(_name "${_file}" NAME)
				IF(IS_SYMLINK "${_file}")
					FILE(READ_SYMLINK "${_file}" _real_file)
					IF(IS_SYMLINK "${_real_file}")
						MESSAGE(FATAL_ERROR "Only one level symlinks are allowed - ${_file}")
					ENDIF()
					GET_FILENAME_COMPONENT(_filename "${_real_file}" NAME)
					LIST(APPEND symlink_list          "${_name}")
					LIST(APPEND symlink_filename_list "${_filename}")
					CMAKE_PATH(IS_RELATIVE _real_file _real_file_is_relative)
					IF(_real_file_is_relative)
						GET_FILENAME_COMPONENT(_basepath "${_file}" DIRECTORY)
						CMAKE_PATH(ABSOLUTE_PATH _real_file BASE_DIRECTORY "${_basepath}" NORMALIZE)
					ENDIF()
					LIST(APPEND filepath_list_filtered "${_real_file}")
					LIST(APPEND filename_list          "${_filename}")
				ELSE()
					LIST(APPEND filepath_list_filtered "${_file}")
					LIST(APPEND filename_list          "${_name}")
				ENDIF()
            ENDFOREACH()

			LIST(REMOVE_DUPLICATES filepath_list_filtered)
			FOREACH(_filepath IN LISTS filepath_list_filtered)
        		INSTALL(FILES "${_filepath}" DESTINATION ${install_dir})
			ENDFOREACH()

			FOREACH(real_filename symlink_name IN ZIP_LISTS symlink_filename_list symlink_list)
				IF(real_filename STREQUAL symlink_name)
					CONTINUE()
				ENDIF()
				_BA_PACKAGE_DEPS_INSTALL_SHARED_LIBRARY_SYMLINK("${real_filename}" "${symlink_name}")
			ENDFOREACH()
		
			LIST(REMOVE_DUPLICATES symlink_filename_list)
			LIST(REMOVE_DUPLICATES filename_list)
            SET(filenames "${filenames};${filename_list};${symlink_filename_list};${symlink_list}")
		ENDIF()
    	_BA_PACKAGE_DEPS_GET_DEPENDENCIES_FILES(${library} filenames)
		LIST(REMOVE_DUPLICATES filenames)
	ENDFOREACH()

    SET(${filenames_for_patchelf_var} ${filenames} PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# It tries to get IMPORTED_LOCATION from the target.
#
# If the IMPORTED_LOCATION property does not exist try to find
# IMPORTED_LOCATION_${CMAKE_BUILD_TYPE}.
#
# IMPORTED_LOCATION_${CMAKE_BUILD_TYPE} does not exist try to crawl thru
# all supported build types (except ${CMAKE_BUILD_TYPE}).
# Function returns first existing IMPORTED_LOCATION_<build_type>.
#
# If not IMPORTED_LOCATION found then the <output_var> is unset in the calling context.
#
# <function> (
#   <target> <output_var>
# )
#
FUNCTION(_BA_PACKAGE_DEPS_GET_IMPORTED_LOCATION target output_var)
	SET(filepath)
	STRING(TOUPPER "${CMAKE_BUILD_TYPE}" build_type_upper)
	_BA_PACKAGE_DEPS_GET_IMPORTED_LOCATION_FOR_BUILD_TYPE(${target} ${CMAKE_BUILD_TYPE} filepath)
	IF(NOT filepath)
		SET(build_type_list ${CMDEF_BUILD_TYPE_LIST_UPPERCASE})
		LIST(REMOVE_ITEM build_type_list ${build_type_upper})
		GET_TARGET_PROPERTY(imported_configurations ${target} IMPORTED_CONFIGURATIONS)
		LIST(APPEND build_type_list "${imported_configurations}")
		FOREACH(build_type IN LISTS build_type_list)
			_BA_PACKAGE_DEPS_GET_IMPORTED_LOCATION_FOR_BUILD_TYPE(${target} ${build_type} filepath)
			IF(filepath)
				BREAK()
			ENDIF()
		ENDFOREACH()
	ENDIF()
	IF(NOT "${filepath}" STREQUAL "filepath-NOTFOUND")
		SET(${output_var} "${filepath}" PARENT_SCOPE)
		RETURN()
	ENDIF()
	UNSET(${output_var} PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# Function returns IMPORTED_LOCATION (or IMPORTED_LOCATION_${build_type_uppercase})
# in the ${output_var} variable.
#
# If no IMPORTED_LOCATION found the ${output_var} is unset in the calling context.
#
# <function> (
#   <target> <build_type> <output_var>
# )
#
FUNCTION(_BA_PACKAGE_DEPS_GET_IMPORTED_LOCATION_FOR_BUILD_TYPE target build_type output_var)
	STRING(TOUPPER "${build_type}" build_upper)
	GET_TARGET_PROPERTY(imported_location_${build_upper} ${target} IMPORTED_LOCATION_${build_upper})
	GET_TARGET_PROPERTY(imported_location ${target} IMPORTED_LOCATION)
	IF(NOT "${imported_location_${build_upper}}" STREQUAL "imported_location_${build_upper}-NOTFOUND")
		SET(${output_var} "${imported_location_${build_upper}}" PARENT_SCOPE)
	ELSEIF(NOT "${imported_location}" STREQUAL "imported_location-NOTFOUND")
		SET(${output_var} "${imported_location}" PARENT_SCOPE)
	ELSE()
		UNSET(${output_var} PARENT_SCOPE)
	ENDIF()
ENDFUNCTION()



## Helper
#
# Get all potential SONAME library paths in the same directory
# where the original library is located
#
# <function> (
# 	<abs_path_to_library> <output_list_var>
# )
#
FUNCTION(_BA_PACKAGE_DEPS_GET_ALL_SONAME_FILES abspath_to_library out_list_var)
	GET_FILENAME_COMPONENT(abs_directory_path "${abspath_to_library}" DIRECTORY)
	GET_FILENAME_COMPONENT(library_name       "${abspath_to_library}" NAME)
	FILE(GLOB list_of_files LIST_DIRECTORIES OFF "${abs_directory_path}/${library_name}*")
	SET(${out_list_var} "${list_of_files}" PARENT_SCOPE)
ENDFUNCTION()



## Helper
#
# Function creates symlinks for a given shared library name.
#
# <function> (
#	<shared_library_name> // shared library name (the real one)
#	<symlink_name>        // symlink (in many cases SONAME of the shared library)
# )
#
FUNCTION(_BA_PACKAGE_DEPS_INSTALL_SHARED_LIBRARY_SYMLINK shared_library_name symlink_name)
	INSTALL(CODE "SET(_ba_package_deps_library_name ${shared_library_name})")
	INSTALL(CODE "SET(_ba_package_deps_link_name    ${symlink_name})")
	INSTALL(CODE "SET(_ba_package_deps_install_dir  ${CMDEF_LIBRARY_INSTALL_DIR})")
	INSTALL(CODE [[
		SET(destdir "$ENV{DESTDIR}")
		SET(working_directory)
		IF(destdir)
			SET(working_directory "${destdir}/${CMAKE_INSTALL_PREFIX}/${_ba_package_deps_install_dir}")
		ELSE()
			SET(working_directory "${CMAKE_INSTALL_PREFIX}/${_ba_package_deps_install_dir}")
		ENDIF()
		EXECUTE_PROCESS(
			COMMAND ${CMAKE_COMMAND} -E create_symlink ${_ba_package_deps_library_name} ${_ba_package_deps_link_name}
			RESULT_VARIABLE    result
			WORKING_DIRECTORY "${working_directory}"
		)
		IF(NOT result EQUAL 0)
			MESSAGE(FATAL_ERROR "Cannot create symlink ${_ba_package_deps_link_name}")
		ENDIF()
	]])
ENDFUNCTION()
