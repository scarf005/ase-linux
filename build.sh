#!/bin/bash

# build script to build cmake to build ninja to build aseprite

build_skia() {
  mkdir -p deps
  cd deps
  git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git
  git clone --depth 1 -b aseprite-m96 https://github.com/aseprite/skia.git
  export PATH="$PWD/depot_tools:$PATH"
  cd skia
  python tools/git-sync-deps
  gn gen out/Release-x64 \
    --args="is_debug=false is_official_build=true skia_use_system_expat=false skia_use_system_icu=false skia_use_system_libjpeg_turbo=false skia_use_system_libpng=false skia_use_system_libwebp=false skia_use_system_zlib=false skia_use_sfntly=false skia_use_freetype=true skia_use_harfbuzz=true skia_pdf_subset_harfbuzz=true skia_use_system_freetype2=false skia_use_system_harfbuzz=false"
  ninja -C out/Release-x64 skia modules
  cd ../..
}

build_cmake() {
  git clone --depth 1 --recursive https://github.com/aseprite/aseprite.git
  SKIA="$PWD/deps/skia"
  cd aseprite
  mkdir -p build
  cd build
  ls $SKIA
  cmake \
    -G Ninja \
    -DCMAKE_C_COMPILER=$CC \
    -DCMAKE_CXX_COMPILER=$CXX \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_CXX_FLAGS="-Wno-unused-variable -Wno-unused-parameter" \
    -DLAF_BACKEND=skia \
    -DSKIA_DIR=$SKIA \
    -DSKIA_LIBRARY_DIR=$SKIA/out/Release-x64 \
    -DSKIA_LIBRARY=$SKIA/out/Release-x64/libskia.a \
    ..
  cd ..
}

build_aseprite() {
  cd aseprite
  ninja -C build
  cd ..
}

# build_skia
# build_cmake
build_aseprite