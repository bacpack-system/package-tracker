#
# The system builds the app/ and checks
# if all installed dependencies are in place and all
# RPATH/RUNPATH are set up correctly
#

CMAKE_MINIMUM_REQUIRED(VERSION 3.21)

IF(NOT CMAKE_SCRIPT_MODE_FILE)
    MESSAGE(FATAL_ERROR "Please, run this in CMake script mode!")
ENDIF()

FIND_PACKAGE(CMLIB COMPONENTS CMDEF REQUIRED)

##
#
# Function cleans up tests directory
#
FUNCTION(DEPSTEST_CLEANUP dir_to_cleanup)
    FIND_PROGRAM(git git REQUIRED)
    EXECUTE_PROCESS(
        COMMAND           "${git}" "clean" "-xfd" "."
        WORKING_DIRECTORY "${dir_to_cleanup}"
        RESULT_VARIABLE   git_clean_result
    )
    IF(NOT git_clean_result EQUAL 0)
        MESSAGE(FATAL_ERROR "Cannot clean up test directory!")
    ENDIF()
ENDFUNCTION()

##
#
# Function builds all needed dependencies, installs them
# and test if testapp install directory is consistent
# <function> (
#       testbase_path   // absolute path to the topmost dir with tests
#       testfile_name   // name of the testfile from testbase_path
#       app_build_dir   // where to create a build
#       app_install_dir // where to install test app
# )
#
FUNCTION(DEPSTEST_RUN_AND_EVALUATE testbase_path testfile_name app_build_dir app_install_dir)
    SET(testapp_build_dir   "${app_build_dir}")
    SET(testapp_install_dir "${app_install_dir}")
    SET(testapp_source_dir  "${CMAKE_CURRENT_LIST_DIR}/app")
    FILE(MAKE_DIRECTORY "${testapp_build_dir}")
    EXECUTE_PROCESS(
        COMMAND "${CMAKE_COMMAND}"
            "-DBA_PACKAGE_TEST_NAME=${testfile_name}"
            "-DCMAKE_BUILD_TYPE=Release"
            "-DCMAKE_INSTALL_PREFIX=${testapp_install_dir}"
            "${testapp_source_dir}"
        WORKING_DIRECTORY "${testapp_build_dir}"
        RESULT_VARIABLE test_configure_result
    )
    IF(NOT test_configure_result EQUAL 0)
        MESSAGE(FATAL_ERROR "test '${testfile_name}' - configure failed!")
    ENDIF()
    EXECUTE_PROCESS(
        COMMAND "${CMAKE_COMMAND}" "--build" "."
        WORKING_DIRECTORY "${testapp_build_dir}"
        RESULT_VARIABLE test_build_result
    )
    IF(NOT test_build_result EQUAL 0)
        MESSAGE(FATAL_ERROR "test '${testfile_name}' - build failed!")
    ENDIF()
    EXECUTE_PROCESS(
        COMMAND "${CMAKE_COMMAND}" "--install" "."
        WORKING_DIRECTORY "${testapp_build_dir}"
        RESULT_VARIABLE test_install_result
    )
    IF(NOT test_install_result EQUAL 0)
        MESSAGE(FATAL_ERROR "test '${testfile_name}' - install failed!")
    ENDIF()
    INCLUDE("${testbase_path}/${testfile_name}")
    IF(NOT COMMAND TEST_GET_EXPECTED_INSTALLED_FILES_LIST)
        MESSAGE(FATAL_ERROR "In the test ${testfile_name} the function TEST_GET_EXPECTED_INSTALLED_FILES_LIST is not found!")
    ENDIF()
    SET(destdir)
    IF(NOT "$ENV{DESTDIR}" STREQUAL "")
        SET(destdir "$ENV{DESTDIR}/")
    ENDIF()
    TEST_GET_EXPECTED_INSTALLED_FILES_LIST(expected_testapp_installed_file_list)
    FOREACH(expected_file_path IN LISTS expected_testapp_installed_file_list)
        IF(NOT EXISTS "${destdir}${testapp_install_dir}/${expected_file_path}")
            MESSAGE(FATAL_ERROR "Error: expected file '${expected_file_path}' is not in the testapp install directory")
        ENDIF()
    ENDFOREACH()
ENDFUNCTION()

##
#
# Function check if the RUNPATH for binary and all shared libraries
# is set as expected.
# If not FATAL_ERROR is omitted.
#
# <function> (
#       app_install_dir // where the testapp is installed
# )
#
FUNCTION(DEPSTEST_CHECK_RUNPATH app_install_dir)
    MESSAGE(STATUS "Checking R/RUNPATH.")
    FIND_PROGRAM(readelf readelf REQUIRED)
    SET(bin_dir "${app_install_dir}/${CMDEF_BINARY_INSTALL_DIR}")
    SET(lib_dir "${app_install_dir}/${CMDEF_LIBRARY_INSTALL_DIR}")
    FILE(GLOB binfile_list "${bin_dir}/*")
    FILE(GLOB libfile_list LIST_DIRECTORIES FALSE "${lib_dir}/*")

    FILE(RELATIVE_PATH expected_bin_file_path "${bin_dir}" "${lib_dir}")
    SET(expected_binfile_runpath "$ORIGIN/${expected_bin_file_path}")
    SET(expected_libfile_runpath "$ORIGIN")

    # TODO make a function!
    FOREACH(binary_file_path IN LISTS binfile_list)
        EXECUTE_PROCESS(
            COMMAND ${readelf} -d "${binary_file_path}"
            OUTPUT_VARIABLE readelf_output
            RESULT_VARIABLE readelf_result
        )
        IF(NOT readelf_result EQUAL 0)
            MESSAGE(FATAL_ERROR "Cannot run readelf! ${binary_file_path}")
        ENDIF()
        STRING(REGEX MATCH "Library runpath: \\[([^\\)]+)\\]" runpath_exist "${readelf_output}")
        IF(NOT runpath_exist)
            MESSAGE(FATAL_ERROR "Cannot find RUNPATH by readelf. Error! ${readelf_output}")
        ENDIF()
        SET(actual_runpath "${CMAKE_MATCH_1}")
        IF(NOT expected_binfile_runpath STREQUAL actual_runpath)
            MESSAGE(FATAL_ERROR "Invalid RUNPATH: '${actual_runpath}', expected: '${expected_binfile_runpath}'")
        ENDIF()
    ENDFOREACH()
    FOREACH(library_file_path IN LISTS libfile_list)
        EXECUTE_PROCESS(
            COMMAND ${readelf} -d "${library_file_path}"
            OUTPUT_VARIABLE readelf_output
            RESULT_VARIABLE readelf_result
        )
        IF(NOT readelf_result EQUAL 0)
            MESSAGE(FATAL_ERROR "Cannot run readelf! ${library_file_path}")
        ENDIF()
        STRING(REGEX MATCH "Library runpath: \\[([^\\)]+)\\]" runpath_exist "${readelf_output}")
        IF(NOT runpath_exist)
            MESSAGE(FATAL_ERROR "Cannot find RUNPATH be readelf. Error! ${readelf_output}")
        ENDIF()
        SET(actual_runpath "${CMAKE_MATCH_1}")
        IF(NOT expected_libfile_runpath STREQUAL actual_runpath)
            MESSAGE(FATAL_ERROR "Invalid RUNPATH: '${actual_runpath}', expected: '${expected_libfile_runpath}'")
        ENDIF()
    ENDFOREACH()
ENDFUNCTION()

##
#
# It checks that there are no symlinks which point
# to absolute file/dir path
#
# <function>(
#       app_install_dir // where the testapp is installed
# )
#
FUNCTION(DEPSTEST_CHECK_SYMLINKS app_install_dir)
    MESSAGE(STATUS "Checking symlinks.")
    SET(lib_dir "${app_install_dir}/${CMDEF_LIBRARY_INSTALL_DIR}")
    FILE(GLOB_RECURSE libfile_list LIST_DIRECTORIES FALSE "${lib_dir}/*")
    FOREACH(file IN LISTS libfile_list)
        IF(NOT IS_SYMLINK file)
            CONTINUE()
        ENDIF()
        GET_FILENAME_COMPONENT(real_path "${file}" REALPATH)
        IF(NOT EXISTS "${real_path}")
            MESSAGE(FATAL_ERROR "Broken symlink detected: ${file} -> ${symlink_target}")
        ENDIF()
        FILE(READ_SYMLINK "${file}" symlink_target)
        IF(IS_ABSOLUTE symlink_target)
            MESSAGE(FATAL_ERROR "Absolute symlink detected: ${file} -> ${symlink_target}\nAll symlinks must use relative paths.")
        ENDIF()
    ENDFOREACH()
ENDFUNCTION()



OPTION(TEST_WITH_DESTDIR "If ON it uses/defines DESTDIR while running set of tests. If OFF do not use DESTDIR." OFF)
SET(TEST_BASE_PATH    "${CMAKE_CURRENT_LIST_DIR}/app/tests_list")
SET(TESTAPP_BUILD_DIR "${CMAKE_CURRENT_LIST_DIR}/testapp_build")
SET(TESTAPP_INSTALL_DIR)

IF(TEST_WITH_DESTDIR)
    IF(NOT "$ENV{DESTDIR}" STREQUAL "")
        MESSAGE(FATAL_ERROR "Oh, DESTDIR already set, please unset DESTDIR env. variable!")
    ENDIF()
    SET(destdir "${CMAKE_CURRENT_LIST_DIR}/destdir")
    SET(ENV{DESTDIR}        "${destdir}")
    SET(TESTAPP_INSTALL_DIR "/testapp_install_destdir")
ELSE()
    SET(TESTAPP_INSTALL_DIR "${CMAKE_CURRENT_LIST_DIR}/testapp_install")
ENDIF()

FILE(GLOB tests_name_list RELATIVE "${TEST_BASE_PATH}" "${TEST_BASE_PATH}/*")
FOREACH(testfile_name IN LISTS tests_name_list)
    DEPSTEST_CLEANUP("${CMAKE_CURRENT_LIST_DIR}")
    DEPSTEST_RUN_AND_EVALUATE("${TEST_BASE_PATH}" ${testfile_name} "${TESTAPP_BUILD_DIR}" "${TESTAPP_INSTALL_DIR}")
    DEPSTEST_CHECK_RUNPATH("${TESTAPP_INSTALL_DIR}")
    DEPSTEST_CHECK_SYMLINKS("${TESTAPP_INSTALL_DIR}")
ENDFOREACH()
DEPSTEST_CLEANUP("${CMAKE_CURRENT_LIST_DIR}")