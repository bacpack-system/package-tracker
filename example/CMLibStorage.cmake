SET(STORAGE_LIST DEP)

FIND_PACKAGE(CMLIB REQUIRED COMPONENTS CMCONF)

#
# Init Global Conf system with name "EXAMPLE"
#
CMCONF_INIT_SYSTEM(EXAMPLE)

SET(STORAGE_LIST_DEP "https://github.com/bacpack-system/package-tracker.git")