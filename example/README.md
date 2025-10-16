
# BringAuto Package Tracker Example

Sample application with a CURL package to show content of example.com domain.

The project uses [example-context] as the source of dependency definitions.

- install [CMake-lib]
- prepare clean Package Repository and use [Packager] to build packages.
  Details at [example usage documentation].
- do not forget to install [CMCONF Configration] of [example-project]
- open terminal in Package Tracker example directory (this one) and run
  - `export BA_PACKAGE_LOCAL_PATH=<path_to_local_repo>` where `<path_to_local_repo>` is the absolute path to the local Package Repository.
  - `mkdir _b; cd _b; cmake ../`
    - for binary run `make`
    - then for package run `cpack`


[CMCONF Configuration]: https://github.com/bacpack-system/example-context/tree/master/config
[CMake-lib]: https://github.com/cmakelib/cmakelib
[example-context]: https://github.com/bacpack-system/example-context
[example-project]: https://github.com/bacpack-system/example-project
[Packager]: https://github.com/bacpack-system/packager
[example usage documentation]: https://bacpack-system.github.io/example_usage
