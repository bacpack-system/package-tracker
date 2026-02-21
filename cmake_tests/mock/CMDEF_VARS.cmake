##
#
# Mock CMDEF variables for testing BA_PACKAGE_LIBRARY
#
# This file provides deterministic CMDEF_* variables that would normally be
# detected from the system by CMDEF. Using fictional values ensures tests
# produce consistent results and do not accidentally match real system values.
#
# Variables provided:
#   CMDEF_ARCHITECTURE      - CPU architecture
#   CMDEF_DISTRO_ID         - Linux distribution ID
#   CMDEF_DISTRO_VERSION_ID - Distribution version
#
# Usage:
#   Include this file AFTER BA_PACKAGE.cmake to override the real CMDEF values.
#

SET(CMDEF_ARCHITECTURE "mock_arch"
    CACHE INTERNAL
    "Mock CPU architecture for testing"
)
SET(CMDEF_DISTRO_ID "mock_distro"
    CACHE INTERNAL
    "Mock Linux distribution ID for testing"
)
SET(CMDEF_DISTRO_VERSION_ID "0.0.0"
    CACHE INTERNAL
    "Mock distribution version for testing"
)

