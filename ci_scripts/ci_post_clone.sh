#!/bin/sh
set -e

echo "Running Xcode Cloud Flutter post-clone setup"

cd "$CI_PRIMARY_REPOSITORY_PATH"

FLUTTER_HOME="$HOME/flutter"
export PATH="$FLUTTER_HOME/bin:$PATH"

if [ ! -d "$FLUTTER_HOME/.git" ]; then
  echo "Installing Flutter stable..."
  rm -rf "$FLUTTER_HOME"
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$FLUTTER_HOME"
else
  echo "Updating Flutter stable..."
  git -C "$FLUTTER_HOME" fetch origin stable --depth 1
  git -C "$FLUTTER_HOME" checkout stable
  git -C "$FLUTTER_HOME" reset --hard origin/stable
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
if [ -n "$CI_BUILD_NUMBER" ]; then
  flutter build ios --config-only --release --build-number="$CI_BUILD_NUMBER"
else
  flutter build ios --config-only --release
fi

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
