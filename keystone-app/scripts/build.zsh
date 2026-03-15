#!/usr/bin/env zsh
set -e

APP_NAME="Keystone"
BUNDLE_ID="com.mabino.keystone"

echo "🔨 Building Keystone Native..."
swift build -c release
BIN_PATH=$(swift build -c release --show-bin-path)/Keystone

echo "📦 Creating App Bundle..."
APP_BUNDLE="build/${APP_NAME}.app"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy binary
cp "$BIN_PATH" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

# Copy icon
if [[ -f "Keystone/Resources/AppIcon.icns" ]]; then
    cp "Keystone/Resources/AppIcon.icns" "${APP_BUNDLE}/Contents/Resources/"
fi

# Create Info.plist
cat > "${APP_BUNDLE}/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>${BUNDLE_ID}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "✅ Build complete: keystone-app/${APP_BUNDLE}"
echo "💡 You can now drag this app to your Applications folder."
