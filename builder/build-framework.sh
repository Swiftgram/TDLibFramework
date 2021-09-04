#!/bin/sh

PLATFORM="$1"

if [[ $PLATFORM = "iOS" ]]; then
    SDK="iphoneos"
elif [[ $PLATFORM = "iOS-simulator" ]]; then
    SDK="iphonesimulator"
elif [[ $PLATFORM = "macOS" ]]; then
    SDK="macosx"
elif [[ $PLATFORM = "watchOS" ]]; then
    SDK="watchos"
elif [[ $PLATFORM = "watchOS-simulator" ]]; then
    SDK="watchsimulator"
elif [[ $PLATFORM = "tvOS" ]]; then
    SDK="appletvos"
elif [[ $PLATFORM = "tvOS-simulator" ]]; then
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
    SKIP_INSTALL=NO
