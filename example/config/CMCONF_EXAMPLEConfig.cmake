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

#
# It works for a publicly accessible repository.
#
CMCONF_SET(BA_PACKAGE_GIT_ARCHIVE_PATH_TEMPLATE "")
CMCONF_SET(BA_PACKAGE_HTTP_HEADER "")
CMCONF_SET(BA_PACKAGE_TEMPLATE_ARGS_URI_ESCAPE OFF)
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
#CMCONF_SET(BA_PACKAGE_HTTP_HEADER "Authorization: token <token>")
#CMCONF_SET(BA_PACKAGE_URI_TEMPLATE_REMOTE "https://gitea.example.com/username/repository/raw/<REVISION>/package/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>")

#
# Gitlab hosted private Package Repository.
# gitlab_project_id is the id of the project in Gitlab. It can be found in General setting page of the project
#
#SET(gitlab_project_id 000)
#CMCONF_SET(BA_PACKAGE_TEMPLATE_ARGS_URI_ESCAPE ON)
#CMCONF_SET(BA_PACKAGE_HTTP_HEADER "PRIVATE-TOKEN: $ENV{GITLAB_TOKEN}")
#CMCONF_SET(BA_PACKAGE_URI_TEMPLATE_REMOTE "https://gitlab.example.com/api/v4/projects/${gitlab_project_id}/repository/files/package%2F<GIT_PATH>%2F<PACKAGE_GROUP_NAME>%2F<ARCHIVE_NAME>/raw?ref=<REVISION>&lfs=true")