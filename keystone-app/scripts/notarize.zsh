#!/usr/bin/env zsh
set -e

# Configuration (Fill these in)
APP_NAME="Keystone"
BUNDLE_ID="com.mabino.keystone"
DEVELOPER_ID="Developer ID Application: Your Name (TeamID)"
APPLE_ID="your@email.com"
APP_SPECIFIC_PASSWORD="your-app-password"

echo "🔐 Notarizing $APP_NAME..."

# 1. Build and create App Bundle (simplified for this script)
swift build -c release
BINARY_PATH=$(swift build -c release --show-bin-path)/Keystone

# In a real scenario, you'd create a proper .app bundle here.
# For now, we'll zip the binary.
ZIP_PATH="/tmp/${APP_NAME}.zip"
zip -j "$ZIP_PATH" "$BINARY_PATH"

echo "📤 Submitting to Apple Notarization Service..."
xcrun notarytool submit "$ZIP_PATH" \
    --apple-id "$APPLE_ID" \
    --password "$APP_SPECIFIC_PASSWORD" \
    --team-id "YOUR_TEAM_ID" \
    --wait

echo "✅ Notarization complete."
