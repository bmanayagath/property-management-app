#!/bin/sh
set -e

echo "Running Xcode Cloud Flutter prebuild script"

cd "$CI_PRIMARY_REPOSITORY_PATH"

export PATH="$PATH:$HOME/flutter/bin"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Installing Flutter stable..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
  export PATH="$PATH:$HOME/flutter/bin"
fi

echo "Current directory:"
pwd

echo "Flutter version:"
flutter --version

echo "Flutter doctor:"
flutter doctor -v

echo "Disabling Flutter Swift Package Manager integration"
flutter config --no-enable-swift-package-manager

echo "Cleaning Flutter project"
flutter clean

echo "Getting Flutter packages"
flutter pub get

echo "Generating Flutter iOS config"
flutter build ios --config-only --release

echo "Checking Generated.xcconfig"
ls -la ios/Flutter/

echo "Installing CocoaPods"
cd ios
pod deintegrate || true
pod install --repo-update
cd ..

echo "Checking Pods support files"
ls -la ios/Pods/Target\ Support\ Files/Pods-Runner/

echo "Flutter Xcode Cloud setup completed"
