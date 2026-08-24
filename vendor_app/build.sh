#!/bin/bash

echo "Generating .env file from Vercel Environment Variables..."
cat <<EOF > .env
GEMINI_API_KEY=$GEMINI_API_KEY
CLOUDINARY_CLOUD_NAME=$CLOUDINARY_CLOUD_NAME
CLOUDINARY_UPLOAD_PRESET=$CLOUDINARY_UPLOAD_PRESET
FIREBASE_API_KEY=$FIREBASE_API_KEY
FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID
FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID
FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET
FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN
FIREBASE_MEASUREMENT_ID=$FIREBASE_MEASUREMENT_ID
FIREBASE_APP_ID_WEB=$FIREBASE_APP_ID_WEB
EOF

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
