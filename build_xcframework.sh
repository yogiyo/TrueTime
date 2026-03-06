#!/bin/bash
# ./build_xcframework.sh "YOUR_KEY"
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Error: 코드사인 Identity를 인자로 전달해주세요."
    echo "Usage: $0 <CODE_SIGN_IDENTITY>"
    echo "Example: $0 \"<SIGNING_IDENTITY or KEY_ID>\""
    exit 1
fi

CODE_SIGN_IDENTITY="$1"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$PROJECT_DIR/build"
BINARY_DIR="$PROJECT_DIR/Binary"
PROJECT="$PROJECT_DIR/TrueTime.xcodeproj"
FRAMEWORK_NAME="TrueTime"
DATE_SUFFIX=$(date +"%Y%m%d")
OUTPUT_DIR="$BINARY_DIR/${FRAMEWORK_NAME}_${DATE_SUFFIX}"

echo "==> 빌드 디렉토리 정리..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "==> iOS 아카이브..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme TrueTime-iOS \
    -destination "generic/platform=iOS" \
    -archivePath "$BUILD_DIR/$FRAMEWORK_NAME-iOS.xcarchive" \
    SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    | tail -1

echo "==> iOS Simulator 아카이브..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme TrueTime-iOS \
    -destination "generic/platform=iOS Simulator" \
    -archivePath "$BUILD_DIR/$FRAMEWORK_NAME-iOS-Simulator.xcarchive" \
    SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    | tail -1

echo "==> macOS 아카이브..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme TrueTime-Mac \
    -destination "generic/platform=macOS" \
    -archivePath "$BUILD_DIR/$FRAMEWORK_NAME-Mac.xcarchive" \
    SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
    | tail -1

echo "==> XCFramework 생성..."
xcodebuild -create-xcframework \
    -archive "$BUILD_DIR/$FRAMEWORK_NAME-iOS.xcarchive" -framework "$FRAMEWORK_NAME.framework" \
    -archive "$BUILD_DIR/$FRAMEWORK_NAME-Mac.xcarchive" -framework "$FRAMEWORK_NAME.framework" \
    -archive "$BUILD_DIR/$FRAMEWORK_NAME-iOS-Simulator.xcarchive" -framework "$FRAMEWORK_NAME.framework" \
    -output "$BUILD_DIR/$FRAMEWORK_NAME.xcframework"

echo "==> 코드사인..."
codesign --timestamp -s "$CODE_SIGN_IDENTITY" "$BUILD_DIR/$FRAMEWORK_NAME.xcframework"

echo "==> $OUTPUT_DIR 로 이동..."
mkdir -p "$OUTPUT_DIR"
mv "$BUILD_DIR/$FRAMEWORK_NAME.xcframework" "$OUTPUT_DIR/"

echo ""
echo "==> 완료: $OUTPUT_DIR/$FRAMEWORK_NAME.xcframework"
