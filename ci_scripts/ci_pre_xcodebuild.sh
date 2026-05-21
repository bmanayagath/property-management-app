#!/bin/sh
set -e

cd "$CI_WORKSPACE"

export PATH="$PATH:$HOME/flutter/bin"

if ! command -v flutter >/dev/null 2>&1; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
  export PATH="$PATH:$HOME/flutter/bin"
fi

flutter --version
flutter pub get
flutter build ios --config-only --release

cd ios
pod install --repo-update
cd ..
