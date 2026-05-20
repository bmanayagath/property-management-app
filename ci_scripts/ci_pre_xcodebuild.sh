#!/bin/sh

set -e

echo "Starting Flutter setup for Xcode Cloud..."

flutter pub get

flutter build ios --config-only --release

cd ios
pod install --repo-update
cd ..

echo "Flutter iOS setup completed."
