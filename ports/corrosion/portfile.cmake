vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO corrosion-rs/corrosion
    REF "v0.6.1"
    SHA512 2b0d1ccafd5472f2938d084995662c586f19cb5cd4ead20fa25e9516d595eb5f756cb2d9abb12dccfa944b52a1f8002c69a1a4d955409c9d194c6d885a6d48ca # Replace with accurate sha512
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release)
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCORROSION_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME corrosion
    CONFIG_PATH lib/cmake/Corrosion
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
