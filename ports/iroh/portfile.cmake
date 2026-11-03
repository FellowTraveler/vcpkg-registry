vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO n0-computer/iroh-c-ffi
    REF "v0.101.0"
    SHA512 da670f3770183cc123d1b5092f7f5c7213fddeff128737375ac891233b8db5f6707873bf317ebb6a73acc936f09784a362261eab197089fec67a3ff2f0f76362
    HEAD_REF main
)

file(WRITE "${SOURCE_PATH}/CMakeLists.txt" [[
cmake_minimum_required(VERSION 3.22)
project(iroh VERSION 0.101.0 LANGUAGES C)

find_package(Corrosion CONFIG REQUIRED)

corrosion_import_crate(
    MANIFEST_PATH Cargo.toml
    CRATES iroh-c-ffi
    FEATURES headers
)

corrosion_install(
    TARGETS iroh_c_ffi
    EXPORT iroh-targets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(EXPORT iroh-targets
    FILE irohTargets.cmake
    NAMESPACE iroh::
    DESTINATION lib/cmake/iroh
)

include(CMakePackageConfigHelpers)
configure_package_config_file(
    ${CMAKE_CURRENT_LIST_DIR}/iroh-config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/iroh-config.cmake
    INSTALL_DESTINATION lib/cmake/iroh
)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/iroh-config-version.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/iroh-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/iroh-config-version.cmake
    DESTINATION lib/cmake/iroh
)
]])

file(WRITE "${SOURCE_PATH}/iroh-config.cmake.in" [[
@PACKAGE_INIT@
include("${CMAKE_CURRENT_LIST_DIR}/irohTargets.cmake")
check_required_components(iroh)
]])

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

message(STATUS "Generating Iroh C API header definitions...")

find_program(CARGO cargo REQUIRED)

vcpkg_execute_required_process(
    COMMAND ${CMAKE_COMMAND} -E env
        "CARGO_PKG_NAME=iroh-c-ffi"
        "CARGO_CRATE_NAME=iroh_c_ffi"
        "${CARGO}" run --bin generate_headers --features headers -- "${CURRENT_BUILDTREES_DIR}/staging_iroh.h"
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME "generate-headers-cargo-${TARGET_TRIPLET}"
)

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/staging_iroh.h")
    message(FATAL_ERROR "Header generation failed: Host cargo run did not emit target header to disk.")
endif()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include/iroh")

file(COPY "${CURRENT_BUILDTREES_DIR}/staging_iroh.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/iroh")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/iroh/staging_iroh.h" "${CURRENT_PACKAGES_DIR}/include/iroh/iroh.h")

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME iroh
    CONFIG_PATH lib/cmake/iroh
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-MIT")
