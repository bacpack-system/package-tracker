
# Package Tracker Migration Guide - v1 to v2

It describes how to migrate CMake projects for use with Package Tracker `v2.0.0`.

## Changes

- `BA_PACKAGE_HTTP_AUTHORIZATION_HEADER` CMCONF variable renamed to `BA_PACKAGE_HTTP_HEADER`.
  The value must now contain the full HTTP header (e.g. `Authorization: token <token>`) instead of just the token part.
  Package Tracker no longer prepends `Authorization: ` automatically.
- New required CMCONF variables (must be defined even if empty/OFF):
  - `BA_PACKAGE_GIT_ARCHIVE_PATH_TEMPLATE` — [CMake-lib] template to construct the git archive path.
  - `BA_PACKAGE_TEMPLATE_ARGS_URI_ESCAPE` — if ON, template argument values are percent-encoded before URI expansion.
  - `BA_PACKAGE_HTTP_HEADER` — full HTTP header for accessing Package Repository.

## Use Old Version

To use old version of Package Tracker without the v2 changes, manually set Package Tracker revision to `v1.0.2` in [CMLibStorage.cmake]:

```cmake
SET(STORAGE_LIST_DEP_REVISION "v1.0.2")
```

## Migration Steps

Steps:

- Update [cmakelib] to version v1.3.3
- Rename `BA_PACKAGE_HTTP_AUTHORIZATION_HEADER` to `BA_PACKAGE_HTTP_HEADER` in the CMCONF Config file.
  Prepend `Authorization: ` to the value:

  ```cmake
  # v1
  CMCONF_SET(BA_PACKAGE_HTTP_AUTHORIZATION_HEADER "token <token>")
  # v2
  CMCONF_SET(BA_PACKAGE_HTTP_HEADER "Authorization: token <token>")
  ```

- Add new required CMCONF variables to the CMCONF Config file:

  ```cmake
  CMCONF_SET(BA_PACKAGE_GIT_ARCHIVE_PATH_TEMPLATE "")
  CMCONF_SET(BA_PACKAGE_HTTP_HEADER "")
  CMCONF_SET(BA_PACKAGE_TEMPLATE_ARGS_URI_ESCAPE OFF)
  ```

- Clean all CMake caches and reconfigure the CMake project.

Full CMCONF Config example for v2:

```cmake
FIND_PACKAGE(CMLIB REQUIRED COMPONENTS CMCONF)
CMCONF_INIT_SYSTEM(<system_name>)

CMCONF_SET(BA_PACKAGE_LOCAL_USE OFF)
CMCONF_SET(BA_PACKAGE_LOCAL_PATH "<path_to_local_repo>")

CMCONF_SET(BA_PACKAGE_GIT_ARCHIVE_PATH_TEMPLATE "")
CMCONF_SET(BA_PACKAGE_HTTP_HEADER "")
CMCONF_SET(BA_PACKAGE_TEMPLATE_ARGS_URI_ESCAPE OFF)
CMCONF_SET(BA_PACKAGE_URI_REVISION main)
CMCONF_SET(BA_PACKAGE_URI_TEMPLATE_REMOTE "https://gitea.example.com/username/repository/media/<REVISION>/package/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>")
```

Examples for different Package Repository hosting services and authentication methods can be found in [example/], [example-project] and [example-context]


[CMCONF Global Config]: ./GlobalConfiguration.md
[CMLibStorage.cmake]: ../example/CMLibStorage.cmake
[example/]: ../example/
[cmakelib]: https://github.com/cmakelib/cmakelib
[example-project]: https://github.com/bacpack-system/example-project
[example-context]: https://github.com/bacpack-system/example-context