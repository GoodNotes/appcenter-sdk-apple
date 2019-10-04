#!/bin/sh

# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
set -e

# Load custom build config.
if [ -r "${SRCROOT}/../.build_config" ]; then
  source "${SRCROOT}/../.build_config"
  echo "MS_ARM64E_XCODE_PATH: " $MS_ARM64E_XCODE_PATH
else
  echo "Couldn't find custom build config"
fi

# Sets the target folders and the final framework product.
TARGET_NAME="${PROJECT_NAME} iOS Framework"

echo "Building ${TARGET_NAME}."

# Install dir will be the final output to the framework.
# The following line create it in the root folder of the current project.
PRODUCTS_DIR="${SRCROOT}/../AppCenter-SDK-Apple/iOS"

# Working dir will be deleted after the framework creation.
WORK_DIR=build
DEVICE_DIR="${WORK_DIR}/iphoneos.xcarchive"
SIMULATOR_DIR="${WORK_DIR}/iphonesimulator.xcarchive"
CATALYST_DIR="${WORK_DIR}/maccatalyst.xcarchive"

# Make sure we're inside $SRCROOT.
cd "${SRCROOT}"

# Cleaning previous build.
xcodebuild -project "${PROJECT_NAME}.xcodeproj" -configuration "Release" -target "${TARGET_NAME}" clean 

# Building all architectures.
xcodebuild archive -scheme "${TARGET_NAME}" -archivePath "${DEVICE_DIR}" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme "${TARGET_NAME}" -archivePath "${SIMULATOR_DIR}" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme "${TARGET_NAME}" -archivePath "${CATALYST_DIR}" -destination 'platform=macOS,arch=x86_64,variant=Mac Catalyst' SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

# Cleaning the previous build.
if [ -d "${PRODUCTS_DIR}/${PROJECT_NAME}.xcframework" ]; then
  rm -rf "${PRODUCTS_DIR}/${PROJECT_NAME}.xcframework"
fi

# Creates and renews the final product folder.
mkdir -p "${PRODUCTS_DIR}"

# Create xcframework from build directory
xcodebuild -create-xcframework \
-framework "${DEVICE_DIR}/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
-framework "${SIMULATOR_DIR}/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
-framework "${CATALYST_DIR}/Products/Library/Frameworks/${PROJECT_NAME}.framework" \
-output "${PRODUCTS_DIR}/${PROJECT_NAME}.xcframework"

open "${PRODUCTS_DIR}"
