#!/bin/sh
set -e

PLATFORM="$1"


if [[ $PLATFORM = "iOS-simulator" ]]; then # no arm64
    SDK="iphonesimulator"
    SCHEME="iOSApp"
    DESTINATION='platform=iOS Simulator,name=iPhone 6,OS=9.0'
elif [[ $PLATFORM = "macOS" ]]; then # no arm64
    SDK="macosx"
    SCHEME="macOSApp"
    DESTINATION='platform=OS X,arch=x86_64'
elif [[ $PLATFORM = "watchOS-simulator" ]]; then # no arm64
    SDK="watchsimulator"
    SCHEME="watchOSApp"
    DESTINATION='platform=watchOS Simulator,name=watch OS,OS=4.0'
elif [[ $PLATFORM = "tvOS-simulator" ]]; then # no arm64
    SDK="appletvsimulator"
    SCHEME="tvOSApp"
    DESTINATION='platform=tvOS Simulator,name=Apple TV,OS=9.0'
else
    echo "Unknown SDK for platform \"$PLATFORM\""
    exit 1
fi

cd Tests/Apps

xcodebuild \
  -scheme ${SCHEME} \
  -sdk ${SDK} \
  -destination "${DESTINATION}" \
  clean test