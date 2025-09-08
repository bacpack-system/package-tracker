
# Package tracker Migration Guide

It Describes how to migrate CMake projects to for use with Package Tracker `v1.0.0`

## Changes

- Package Repository can be downloaded locally not only from remote source.
- Configuration is stored in [CMCONF Global Config] - URIs from which packages are downloaded differs system by system.

## Use Old Version

To use old version of Package Tracker without [CMCONF Global Config], manually set Package Tracker revision to `v0.0.0` in [CMLibStorage.cmake]

```cmake
# In Projects CMLibStorage.cmake
SET(STORAGE_LIST_DEP_REVISION "v0.0.0")
```

## Migration Steps

Since Package Tracker `v1.0.0` the [CMCONF Global Config] is used.
[CMCONF Global Config] requires to work with a system name. The system name is used to retrieve the configuration for the given system.

Steps:

- Update [cmakelib] to version v1.3.2
- Get a name of the system the project belongs to.
- Set system name by `CMCONF_INIT_SYSTEM(<system_name>)` in the Projects [CMLibStorage.cmake]
- Install [CMCONF Global Config] for the system (it shall by part of Packager Context of the System).
- Clean all CMake caches and reconfigure the CMake project.

Examples can be found in [example/], [example-project] and [example-context]


[CMCONF Global Config]: ./GlobalConfiguration.md
[CMLibStorage.cmake]: ../example/CMLibStorage.cmake
[example/]: ../example/
[cmakelib]: https://github.com/cmakelib/cmakelib
[example-project]: https://github.com/bacpack-system/example-project
[example-context]: https://github.com/bacpack-system/example-context