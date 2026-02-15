
IF(NOT DEFINED BA_PACKAGE_TEST_NAME)
    MESSAGE(FATAL_ERROR "Please specify test to run by CMake variable BA_PACKAGE_TEST_NAME")
ENDIF()

SET(TESTLIST_BASE_PATH "${CMAKE_CURRENT_LIST_DIR}/tests_list/")
SET(TEST_PATH "${CMAKE_CURRENT_LIST_DIR}/tests_list/${BA_PACKAGE_TEST_NAME}")
IF(NOT EXISTS "${TEST_PATH}")
    MESSAGE(FATAL_ERROR "Cannot find test ${TEST_PATH}")
ENDIF()

SET(PROJECT_NAME MyTestApp)

PROJECT(${PROJECT_NAME} LANGUAGES C)
CMAKE_MINIMUM_REQUIRED(VERSION 3.21)

FUNCTION(BUILD_INSTALL_DEPENDENCY install_prefix version dependency_cmake_path)
    EXECUTE_PROCESS(
        COMMAND ${CMAKE_COMMAND} "-DCMAKE_BUILD_TYPE=Release" "-DLIBRARY_VERSION=${version}" "-DCMAKE_INSTALL_PREFIX=${install_prefix}" .
        WORKING_DIRECTORY "${dependency_cmake_path}"
        RESULT_VARIABLE result
    )
    IF(NOT result EQUAL 0)
        MESSAGE(FATAL_ERROR "Cannot configure dependency ${dependency_cmake_path}")
    ENDIF()
    FIND_PROGRAM(GNUMake make)
    EXECUTE_PROCESS(
        COMMAND  ${GNUMake} install
        WORKING_DIRECTORY "${dependency_cmake_path}"
    )
    IF(NOT result EQUAL 0)
        MESSAGE(FATAL_ERROR "Cannot compile dependency ${dependency_cmake_path}")
    ENDIF()
ENDFUNCTION()

FUNCTION(CHECK_BUILD_DEPENDENCY_AGAINST_LIST file_list_getter directory_to_check)
    FILE(GLOB_RECURSE _files
        LIST_DIRECTORIES OFF
        RELATIVE "${directory_to_check}"
        "${directory_to_check}/*"
    )
    CMAKE_LANGUAGE(CALL ${file_list_getter} expected_file_list)
    FOREACH(file IN LISTS _files)
        MESSAGE(STATUS "found file: ${file}")
    ENDFOREACH()
    FOREACH(file IN LISTS expected_file_list) 
        MESSAGE(STATUS "expected file: ${file}")
    ENDFOREACH()
    FOREACH(file IN LISTS _files)
        LIST(FIND expected_file_list "${file}" found)
        IF(found EQUAL -1)
            MESSAGE(FATAL_ERROR "The file was not found: '${file}'")
        ENDIF()
    ENDFOREACH()
ENDFUNCTION()

SET(PROJECT_VERSION 1.5.89)
FIND_PACKAGE(CMLIB COMPONENTS CMDEF REQUIRED)

SET(DEPENDENCY_INSTALL_DIR)
SET(DESTDIR "$ENV{DESTDIR}")
IF(DESTDIR)
    SET(DEPENDENCY_INSTALL_PREFIX "/DependencyRoot")
    SET(DEPENDENCY_INSTALL_DIR    "$ENV{DESTDIR}/DependencyRoot")
ELSE()
    SET(DEPENDENCY_INSTALL_DIR    "${CMAKE_CURRENT_LIST_DIR}/DependencyRoot")
    SET(DEPENDENCY_INSTALL_PREFIX "${DEPENDENCY_INSTALL_DIR}")
ENDIF()
BUILD_INSTALL_DEPENDENCY("${DEPENDENCY_INSTALL_PREFIX}" 1.2.3 ${CMAKE_CURRENT_LIST_DIR}/lib/shared_library_for_prerun)
BUILD_INSTALL_DEPENDENCY("${DEPENDENCY_INSTALL_PREFIX}" 5.67.1 ${CMAKE_CURRENT_LIST_DIR}/lib/shared_library)

INCLUDE("${TEST_PATH}")
IF(NOT COMMAND TEST_PRERUN)
    MESSAGE(FATAL_ERROR "Test is not valid. TEST_PRERUN function not found.")
ENDIF()
IF(NOT COMMAND TEST_PRERUN_GET_EXPECTED_DEPENDENCY_FILE_LIST)
    MESSAGE(FATAL_ERROR "Test is not valid. TEST_PRERUN_GET_EXPECTED_DEPENDENCY_FILE_LIST function not found.")
ENDIF()
IF(NOT COMMAND TEST_POST_TARGET_SETUP)
    MESSAGE(FATAL_ERROR "Test is not valid. TEST_POST_TARGET_SETUP function not found.")
ENDIF()

TEST_PRERUN(
    VERSION     "1.2.3"
    INSTALL_DIR "${DEPENDENCY_INSTALL_DIR}/lib/shared-library-for-prerun"
    LIBRARY_NAME shared-library-for-prerun-shared
)
CHECK_BUILD_DEPENDENCY_AGAINST_LIST(
    TEST_PRERUN_GET_EXPECTED_DEPENDENCY_FILE_LIST
    "${DEPENDENCY_INSTALL_DIR}"
)



LIST(APPEND CMAKE_PREFIX_PATH "${DEPENDENCY_INSTALL_DIR}")
FIND_PACKAGE(shared-library-shared REQUIRED)

ADD_LIBRARY(shared-library-for-prerun-shared SHARED IMPORTED)
SET_TARGET_PROPERTIES(shared-library-for-prerun-shared
    PROPERTIES
        IMPORTED_LOCATION ${DEPENDENCY_INSTALL_DIR}/${CMDEF_LIBRARY_INSTALL_DIR}/shared-library-for-prerun/libshared-library-for-prerun-shared.so.1.2.3
        IMPORTED_SONAME shared-library-for-prerun-shared.so.1.2.3

)

CMDEF_ADD_EXECUTABLE(
    TARGET ${PROJECT_NAME}
    SOURCES main.c
    VERSION ${PROJECT_VERSION}
)
TARGET_LINK_LIBRARIES(${PROJECT_NAME} PUBLIC
    shared-library-shared::shared-library-shared
    shared-library-for-prerun-shared)

TEST_POST_TARGET_SETUP(TARGET ${PROJECT_NAME})

CMDEF_INSTALL(TARGET ${PROJECT_NAME} NAMESPACE ${PROJECT_NAME}::)

# Create a package
CMDEF_PACKAGE(
    MAIN_TARGET ${PROJECT_NAME}
    VERSION     ${PROJECT_VERSION}
)


SET(BA_PACKAGE_CMCONF_USE FALSE
    CACHE BOOL
    "Switch off the CMCONF use for testing purposes."
)
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/../../STORAGE.cmake")

BA_PACKAGE_DEPS_INSTALL_IMPORTED(
    ${PROJECT_NAME}
)
BA_PACKAGE_DEPS_SET_TARGET_RPATH(${PROJECT_NAME})

SET(CPACK_GENERATOR ZIP)
INCLUDE(CPack)

