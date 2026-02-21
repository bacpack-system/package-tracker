# CMake Unit Tests

Unit tests for individual CMake modules (BA_PACKAGE_VARS, BA_PACKAGE, BA_PACKAGE_LIBRARY, etc.).

Tests use mocks to isolate modules from external dependencies (CMLIB, CMDEF, etc.).
Each test is a standalone CMakeLists.txt in its own subdirectory.

## Run

From repository root:

```
cmake -P cmake_tests/CMakeLists.txt
```

## Difference from [test/]

`cmake_tests/` — unit tests for CMake module logic using mocks, no network or build required.

[test/] — integration tests that build a real application, install dependencies, and verify installed file structure.

[test/]: ../test/

