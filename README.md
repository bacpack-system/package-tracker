
# BringAuto Package Tracker

BringAuto package tracker based on [BringAuto Packager] and [CMake-lib]

## Usage

```
# Add package - download, cache and populate
BA_PACKAGE_LIBRARY(nlohmann-json v3.10.5 PLATFORM_STRING_MODE any_machine)
# Find package as described in the library manual 
FIND_PACKAGE(nlohmann_json 3.2.0 REQUIRED)
```

Full example: [example/]

## Requirements

- [CMake-lib] with STORAGE component enabled. One of the storage entry must points to this repo.
- Package Repository that is compliant with [BringAuto Packager] package repository structure.


## Macros

- `BA_PACKAGE_LIBRARY` downloads and init package build by [BringAuto Packager]
- `BA_PACKAGE_DEPS_IMPORTED` installs all imported linked dependencies for a given target
- `BA_PACKAGE_DEPS_SET_TARGET_RPATH` update R/RUNPATH for a given target

## Local vs Remote Package Registry

There are two ways how to access the Package Registry:

- Local: download it locally manually and use "file://" URI scheme to access it.
  It is especially useful when offlie access is needed, for testing purposes
  or for fine grant control over which revision of the Package Registry to use.
- remote: let Package tracker download it from remote repository

Details about how to configure each respective mode in [CMCONF Global Config]

## Settings

Simple Settings to configure Package Tracker.

Package Tracker needs to have [CMCONF] System Name set to retrieve valid confiugration.

Package Tracker is intended to by configured primarily by [CMCONF Global Config].
The Settings is an interface which isolates [CMCONF] from Package Tracker internals.

Setting variables values are highly affected by [CMCONF Global Config].

- `REVISION` - git revision to use when accessing Package Repository.
  Set to [CMCONF Global Config] variable `BA_PACKAGE_URI_REVISION`.
  It has to be set empty for "file://" URI scheme.
- `URI_TEMPLATE` - [CMake-lib] template to construct URI to download package from Package Registry.
   The value is instantiated in cooperation with CMCONF Global Config of Package Tracker.
   The following variables are available for the template:
    - `<REVISION>` - git revision to use when accessing Package Repository.
      Taken from REVISION setting variable. Invalid for "file://" URI type. Switching revisions in local
      Package Repository needs to be managed manually.
    - `<GIT_PATH>` - path to Packages in the repository for a given system. Set to "${CMDEF_DISTRO_ID}/${CMDEF_DISTRO_VERSION_ID}/${CMDEF_ARCHITECTURE}",
    - `<PACKAGE_GROUP_NAME>` - package roup name as stated in [BringAuto Packager Context] 
    - `<ARCHIVE_NAME>` - full name of package of the Package. Set to ${package_group_name}_${version_tag}_${platform_string}.zip

```cmake
# Set REVISION to revision_update
BA_PACKAGE_VARS_SET(REVISION deps_update)
# Obtain nlohmanjson not from default branch but from deps_update branch
BA_PACKAGE_LIBRARY(nlohmann-json v3.10.5 PLATFORM_STRING_MODE any_machine)
```

## FAQ

### Q: Package not found even if it exists in the remote repository

Make sure you choosed correct `PLATFORM_STRING_MODE`.

If package is not bound to the architecture or Linux distro this context info must be passed down by the `PLATFORM_STRING_MODE`.

### Q: Package conflict if I want to build my project by second build type

If you want to use same cache path for Release and Debug build type
you must ensure that the package differ between Debug/Release build config
and does not have files with the same path.

If you have a package that has a same content for Debug and Release you need to
use `NO_DEBUG ON` in `BA_PACKAGE_LIBRARY` otherwise the conflict occure.

(Look at [example/] for quick overview)



[BringAuto Packager]: https://github.com/bringauto/packager
[CMCONF Global Config]: ./doc/GlobalConfiguration.md
[CMake-lib]: https://github.com/cmakelib/cmakelib
[bringAuto Packger Context]: https://github.com/bacpack-system/packager/blob/master/doc/ContextStructure.md
[example/]: example/