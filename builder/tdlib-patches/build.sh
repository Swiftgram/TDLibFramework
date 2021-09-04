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
}

platform="$1"

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
fi

if [[ $platform = "macOS" ]]; then
  set_cmake_options $platform
  build="build-${platform}"
  install="install-${platform}"
  rm -rf $build
  mkdir -p $build
  mkdir -p $install
  cd $build
  cmake $td_path $options -DCMAKE_INSTALL_PREFIX=../${install} -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64"
  make -j3 install || exit
  cd ..
else
  build="build-${platform}"
  install="install-${platform}"
  platform_path=${platform}
  if [[ $simulator = "1" ]]; then
    build="${build}-simulator"
    install="${install}-simulator"
    platform_path="${platform}-simulator"
    ios_platform="SIMULATOR"
  else
    ios_platform="OS"
  fi
  set_cmake_options ${platform_path}
  watchos=""
  if [[ $platform = "watchOS" ]]; then
    ios_platform="WATCH${ios_platform}"
    watchos="-DTD_EXPERIMENTAL_WATCH_OS=ON"
  fi
  if [[ $platform = "tvOS" ]]; then
    ios_platform="TV${ios_platform}"
  fi
  echo $ios_platform
  rm -rf $build
  mkdir -p $build
  mkdir -p $install
  cd $build
  cmake $td_path $options $watchos -DIOS_PLATFORM=${ios_platform} -DCMAKE_TOOLCHAIN_FILE=${td_path}/CMake/iOS.cmake -DCMAKE_INSTALL_PREFIX=../${install}
  make -j3 install || exit
  cd ..
fi