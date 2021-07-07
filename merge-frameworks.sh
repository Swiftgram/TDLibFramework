#!/bin/sh
set -e

PLATFORMS="$1"
FRAMEWORK_NAME=TDLib

xcodebuild_frameworks=()

for PLATFORM in $PLATFORMS;
do
    xcodebuild_frameworks+=(-framework "./build/$PLATFORM.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME-$PLATFORM.framework")
done

# make framework
xcodebuild -create-xcframework \
    "${xcodebuild_frameworks[@]}" \
    -output "./build/$FRAMEWORK_NAME.xcframework"
