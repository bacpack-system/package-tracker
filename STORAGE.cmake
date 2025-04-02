
SET(BRINGAUTO_REPOSITORY_URL_TEMPLATE "https://gitea.bringauto.com/fleet-protocol/package-repository/media/<REVISION>/<GIT_PATH>/<ARCHIVE_NAME>/<PACKAGE_NAME>"
    CACHE STRING
    "Package template for an URI generation"
)

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/BA_PACKAGE_VARS.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/BA_PACKAGE.cmake")
INCLUDE("${CMAKE_CURRENT_LIST_DIR}/BA_PACKAGE_DEPS.cmake")
