#!/bin/sh
set -e

echo "Post clone setup started"

cd "$CI_WORKSPACE"

if ! command -v flutter >/dev/null 2>&1
then
  echo "Flutter not found. Installing Flutter stable..."
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
  export PATH="$PATH:$HOME/flutter/bin"
else
  echo "Flutter already available"
fi

echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.zshrc
export PATH="$PATH:$HOME/flutter/bin"

flutter --version

echo "Post clone setup completed"
