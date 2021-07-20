#!/bin/sh

PLATFORM="$1"

if [[ $PLATFORM = "iOS" ]]; then
    SDK="iphoneos"
elif [[ $PLATFORM = "iOS-simulator" ]]; then # no arm64
    SDK="iphonesimulator"
elif [[ $PLATFORM = "macOS" ]]; then # no arm64
    SDK="macosx"
elif [[ $PLATFORM = "watchOS" ]]; then
    SDK="watchos"
elif [[ $PLATFORM = "watchOS-simulator" ]]; then # no arm64
    SDK="watchsimulator"
elif [[ $PLATFORM = "tvOS" ]]; then
    SDK="appletvos"
elif [[ $PLATFORM = "tvOS-simulator" ]]; then # no arm64
    SDK="appletvsimulator"
else
    echo "Unknown SDK for platform \"$PLATFORM\""
    exit 1
fi

xcodebuild archive \
    -scheme $PLATFORM \
    -archivePath "./build/$PLATFORM.xcarchive" \
    -configuration Release \
    -sdk $SDK \
    BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    SKIP_INSTALL=NO
