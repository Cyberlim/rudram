#!/bin/bash

if [ -d "flutter" ]; then
  echo "Flutter directory exists, pulling latest..."
  cd flutter
  git pull
  cd ..
else
  echo "Cloning Flutter SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 flutter
fi
export PATH="$PATH:`pwd`/flutter/bin"

echo "Flutter Version:"
flutter --version

echo "Enabling Web Support..."
flutter config --enable-web

echo "Building Flutter Web App..."
flutter build web --release
