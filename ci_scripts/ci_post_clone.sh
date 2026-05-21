#!/bin/sh
set -e

echo "Running Xcode Cloud Flutter post-clone setup"

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

echo "Disabling Flutter Swift Package Manager integration"
flutter config --no-enable-swift-package-manager

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

echo "Xcode Cloud Flutter post-clone setup completed"
