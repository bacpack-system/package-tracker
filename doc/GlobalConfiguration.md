
# Package Tracker Global Configuration

Package Tracker uses a [CMCONF] - CMake-lib global configuration module to store and retrieve settings that apply to all packages that
belong to the same System.

[CMCONF] expects the system name to be set by `CMCONF_INIT_SYSTEM(<system_name>)` to be able to get
predefined settings by `CMCONF_GET(<setting_name>)`.

The Configuration is represented as standard Config.cmake file which is installed by symlink
to [CMake User Package Registry]. [CMCONF Example] can be found in [CMCONF] repository.

[CMake User Package Registry]: https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html
[CMCONF]: https://github.com/cmakelib/cmakelib-component-cmconf
[Example]: https://github.com/cmakelib/cmakelib-component-cmconf/tree/main/example


## CMCONF Variables

| Name | Description |
| ---- | ----------- |
| BA_PACKAGE_LOCAL_USE | If set to ON the local Package repository is used. The path to the local Package Repository is set by BA_PACKAGE_LOCAL_PATH or by ENV variable BA_PACKAGE_LOCAL_PATH. If set to OFF the remote URI scheme is used. |
| BA_PACKAGE_LOCAL_PATH | Absolute Path to the local Package Repository. Used if BA_PACKAGE_LOCAL_USE is set to ON. If ENV variable BA_PACKAGE_LOCAL_PATH is set it is used instead of this CMCONF setting. Resulting value is passed to URI_TEMPLATE setting variable as "file://<local_path>/package/<GIT_PATH>/<PACKAGE_GROUP_NAME>/<ARCHIVE_NAME>" |
| BA_PACKAGE_URI_REVISION | Git revision to use when accessing Package Repository. Used if BA_PACKAGE_LOCAL_USE is set to OFF. |
| BA_PACKAGE_URI_TEMPLATE_REMOTE | [CMake-lib] template to construct URI to download package from remote Package Repository. Passed to URI_TEMPLATE setting variable. Used if BA_PACKAGE_LOCAL_USE is set to OFF. |
| BA_PACKAGE_GIT_ARCHIVE_PATH_TEMPLATE | [CMake-lib] template to construct the git archive path. Passed to GIT_PATH_TEMPLATE setting variable. If set the BA_PACKAGE_URI_TEMPLATE_REMOTE shall point to the Git repository and BA_PACKAGE_URI_REVISION is used as Git revision. Used if BA_PACKAGE_LOCAL_USE is set to OFF. |
| BA_PACKAGE_HTTP_HEADER | HTTP header to use when accessing Package Repository. Used if BA_PACKAGE_LOCAL_USE is set to OFF. |
| BA_PACKAGE_TEMPLATE_ARGS_URI_ESCAPE | If set to ON, template argument values (REVISION, GIT_PATH, PACKAGE_GROUP_NAME, ARCHIVE_NAME) are percent-encoded before URI template expansion. Used if BA_PACKAGE_LOCAL_USE is set to OFF. |

## Environment Variables

| Name | Description |
| ---- | ----------- |
| BA_PACKAGE_LOCAL_PATH | Absolute Path to the local Package Repository. If set, Package Tracker behaves as if BA_PACKAGE_LOCAL_USE is set to ON and the local path is set to the value from this ENV variable. |

## URI Examples

Look at [example/config/CMCONF_EXAMPLEConfig.cmake] for examples of URI templates.



[example/config/CMCONF_EXAMPLEConfig.cmake]: ../example/config/CMCONF_EXAMPLEConfig.cmake
[CMCONF Example]: https://github.com/cmakelib/cmakelib-component-cmconf
[CMCONF]:    https://github.com/cmakelib/cmakelib-component-cmconf
[CMake-lib]: https://github.com/cmakelib/cmakelib