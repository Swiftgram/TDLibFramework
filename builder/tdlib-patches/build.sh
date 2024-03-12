#!/bin/sh
td_path=$(grealpath ../..)

rm -rf build
mkdir -p build
cd build

set_cmake_options () {
  # Set CMAKE options depending on platform passed $1
  openssl_path=$(grealpath ../third_party/openssl/$1)
  echo "OpenSSL path = ${openssl_path}"
  openssl_crypto_library="${openssl_path}/lib/libcrypto.a"
  openssl_ssl_library="${openssl_path}/lib/libssl.a"
  options=""
  options="$options -DOPENSSL_FOUND=1"
  options="$options -DOPENSSL_CRYPTO_LIBRARY=${openssl_crypto_library}"
  options="$options -DOPENSSL_SSL_LIBRARY=${openssl_ssl_library}"
  options="$options -DOPENSSL_INCLUDE_DIR=${openssl_path}/include"
  options="$options -DOPENSSL_LIBRARIES=${openssl_crypto_library};${openssl_ssl_library}"
  options="$options -DCMAKE_BUILD_TYPE=Release"
  if command -v ccache &> /dev/null
  then
    echo "ccache available, setting compiler options. Don't trust what cmake says, caching will work. https://t.me/tdlibchat/108338"
    options="$options -DCMAKE_C_COMPILER_LAUNCHER=ccache -DCMAKE_CXX_COMPILER_LAUNCHER=ccache"
  else
    echo "ccache is not available"
  fi
}

platform="$1"
minimum_deployment_version="$2"

# Parse platform and strip simulator
if [[ $platform == *"-simulator" ]]; then
    simulator="1"
else
    simulator="0"
fi

if [[ $platform == "iOS"* ]]; then
    platform="iOS"
elif [[ $platform == "macOS" ]]; then 
    platform="macOS"
elif [[ $platform == "watchOS"* ]]; then
    platform="watchOS"
elif [[ $platform == "tvOS"* ]]; then
    platform="tvOS"
elif [[ $platform == "visionOS"* ]]; then
    platform="visionOS"
fi

echo "Platform = ${platform}"
if [[ $platform = "macOS" ]]; then
  other_options="-DCMAKE_OSX_ARCHITECTURES='x86_64;arm64'"
else
  if [[ $platform = "watchOS" ]]; then
    ios_platform="WATCH"
  elif [[ $platform = "tvOS" ]]; then
    ios_platform="TV"
  elif [[ $platform = "visionOS" ]]; then
    ios_platform="VISION"
  else
    ios_platform=""
  fi

  if [[ $simulator = "1" ]]; then
    platform="${platform}-simulator"
    ios_platform="${ios_platform}SIMULATOR"
  else
    ios_platform="${ios_platform}OS"
  fi

  echo "iOS platform = ${ios_platform}. Minimum OS version ${minimum_deployment_version}"
  other_options="-DIOS_PLATFORM=${ios_platform} -DCMAKE_TOOLCHAIN_FILE=${td_path}/CMake/iOS.cmake -DIOS_DEPLOYMENT_TARGET=${minimum_deployment_version}"
fi

set_cmake_options $platform
build="build-${platform}"
install="install-${platform}"
rm -rf $build
mkdir -p $build
mkdir -p $install
cd $build
cmake $td_path $options $other_options -DCMAKE_INSTALL_PREFIX=../${install}
make -j3 install || exit
cd ..
