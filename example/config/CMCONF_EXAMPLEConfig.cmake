#
# Example configuration.
#

FIND_PACKAGE(CMLIB REQUIRED COMPONENTS CMCONF)

CMCONF_INIT_SYSTEM(EXAMPLE)

#
# It can be used to statically define local Package Repository.
# Not only by BA_PACKAGE_LOCAL_PATH ENV variable.
#
CMCONF_SET(BA_PACKAGE_LOCAL_USE OFF)
CMCONF_SET(BA_PACKAGE_LOCAL_PATH "<path_to_local_repo>")

INCLUDE("${CMAKE_CURRENT_LIST_DIR}/credentials.cmake")
CMCONF_SET(BA_PACKAGE_HTTP_AUTHORIZATION_HEADER "${credentials}")

#
# It works for a publicly accessible repository.
#
CMCONF_SET(BA_PACKAGE_URI_REVISION main)
CMCONF_SET(BA_PACKAGE_URI_TEMPLATE_REMOTE "https://gitea.example.com/username/repository/media/<REVISION>/package/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>")

#
# Gitea hosted public Package Repository:
#
#CMCONF_SET(BA_PACKAGE_URI_TEMPLATE_REMOTE "https://gitea.example.com/username/repository/media/<REVISION>/package/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>")

#
# Gitea hosted private Package Repository.
# Do not forget to specify Access Token
#
#CMCONF_SET(BA_PACKAGE_HTTP_AUTHORIZATION_HEADER "token <token>")
#CMCONF_SET(BA_PACKAGE_URI_TEMPLATE_REMOTE "https://gitea.example.com/username/repository/raw/<REVISION>/package/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>")

#
# Gitlab hosted private Package Repository.
#
#CMCONF_SET(BA_PACKAGE_HTTP_AUTHORIZATION_HEADER "Bearer <token>")
#CMCONF_SET(BA_PACKAGE_URI_TEMPLATE_REMOTE "https://gitlab.example.com/username/repository/-/raw/<REVISION>/package/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>")