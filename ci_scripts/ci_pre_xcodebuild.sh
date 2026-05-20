#!/bin/sh
set -e

echo "Xcode Cloud Flutter setup started"

export PATH="$PATH:$HOME/flutter/bin"

cd "$CI_WORKSPACE"

echo "Current directory:"
pwd

echo "Flutter version:"
flutter --version

echo "Flutter doctor:"
flutter doctor -v

echo "Cleaning Flutter project"
flutter clean

echo "Getting Flutter packages"
flutter pub get

echo "Generating iOS Flutter config files"
flutter build ios --config-only --release

echo "Verifying Generated.xcconfig"
ls -la ios/Flutter/Generated.xcconfig

echo "Installing CocoaPods"
cd ios
pod deintegrate || true
pod install --repo-update
cd ..

echo "Verifying Pods xcfilelists"
ls -la ios/Pods/Target\ Support\ Files/Pods-Runner/

echo "Xcode Cloud Flutter setup completed"
