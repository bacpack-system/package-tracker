
# BringAuto Package Tracker

BringAuto package tracker based on [BringAuto Packager] and [CMake-lib]

## Usage

```
# Add package - download, cache and populate
BA_PACKAGE_LIBRARY(nlohmann-json v3.10.5)
# Find package as described in the library manual
FIND_PACKAGE(nlohmann_json 3.2.0 REQUIRED)
```
BA_PACKAGE_LIBRARY appends the package root to CMAKE_PREFIX_PATH so standard FIND_PACKAGE works.


Full example: [example/]

## Requirements

- [CMake-lib] with STORAGE component enabled. One of the storage entries must point to this repo.
- Package Repository that is compliant with [BringAuto Packager] package repository structure.


## Macros

- `BA_PACKAGE_LIBRARY` downloads and initializes package built by [BringAuto Packager]
- `BA_PACKAGE_DEPS_IMPORTED` installs all imported linked dependencies for a given target
- `BA_PACKAGE_DEPS_SET_TARGET_RPATH` updates R/RUNPATH for a given target

## Local vs Remote Package Repository

There are two ways to access the Package Repository:

- Local: download it locally manually and use "file://" URI scheme to access it.
  It is especially useful when offline access is needed, for testing purposes
  or for fine-grained control over which revision of the Package Repository to use.
- Remote: let Package Tracker download it from a remote Package Repository

Details on how to configure each mode are in [CMCONF Global Config]

## Settings

Simple Settings to configure Package Tracker.

Package Tracker needs to have [CMCONF] System Name set to retrieve valid configuration.

Package Tracker is intended to be configured primarily by [CMCONF Global Config].
The Settings interface isolates [CMCONF] from Package Tracker internals.

Setting variable values are highly affected by [CMCONF Global Config].

- `REVISION` - git revision to use when accessing Package Repository.
  Set to [CMCONF Global Config] variable `BA_PACKAGE_URI_REVISION`.
  It has to be set empty for "file://" URI scheme.
- `URI_TEMPLATE` - [CMake-lib] template to construct URI to download package from Package Repository.
   The value is instantiated in cooperation with CMCONF Global Config of Package Tracker.
   The following variables are available for the template:
    - `<REVISION>` - git revision to use when accessing Package Repository.
      Taken from REVISION setting variable. Invalid for "file://" URI type. Switching revisions in local
      Package Repository needs to be managed manually.
    - `<GIT_PATH>` - path to Packages in the repository for a given system. Set to `${CMDEF_DISTRO_ID}/${CMDEF_DISTRO_VERSION_ID}/${CMDEF_ARCHITECTURE}`,
    - `<PACKAGE_GROUP_NAME>` - package group name as stated in [BringAuto Packager Context]
    - `<ARCHIVE_NAME>` - full name of the Package. Set to ${package_group_name}_${version_tag}_${platform_string}.zip. The platform string is derived from CMDEF variables: `CMDEF_ARCHITECTURE`, `CMDEF_DISTRO_ID`, `CMDEF_DISTRO_VERSION_ID`.

```cmake
# Set REVISION to deps_update
BA_PACKAGE_VARS_SET(REVISION deps_update)
# Obtain nlohmann-json not from default branch but from deps_update branch
BA_PACKAGE_LIBRARY(nlohmann-json v3.10.5)
```

## FAQ

### Q: Package not found even if it exists in the repository

- Ensure the package was built for your platform (CMDEF_DISTRO_ID, CMDEF_DISTRO_VERSION_ID, CMDEF_ARCHITECTURE).
- Verify REVISION and URI_TEMPLATE (see CMCONF Global Config) point to the right Package Repository and branch.
- If using a local Package Repository, confirm BA_PACKAGE_LOCAL_PATH points to the correct directory and that the expected package archive exists.

### Q: Package conflict if I want to build my project by second build type

If you want to use the same cache path for Release and Debug build types
you must ensure that the package differs between Debug/Release build configs
and does not have files with the same paths.

If you have a package that has the same content for Debug and Release you need to
use `NO_DEBUG ON` in `BA_PACKAGE_LIBRARY`; otherwise the conflict will occur.

(Look at [example/] for quick overview)



[BringAuto Packager]: https://github.com/bacpack-system/packager
[CMCONF Global Config]: ./doc/GlobalConfiguration.md
[CMake-lib]: https://github.com/cmakelib/cmakelib
[BringAuto Packager Context]: https://github.com/bacpack-system/packager/blob/master/doc/ContextStructure.md
[example/]: example/