#!/usr/bin/env zsh
set -e

if [[ -z "$1" ]]; then
    echo "Usage: ./release.sh <version>"
    exit 1
fi

VERSION=$1
TAG="v$VERSION"

echo "📦 Releasing Keystone Native $TAG..."

# 1. Build
swift build -c release
BINARY_PATH=$(swift build -c release --show-bin-path)/Keystone

# 2. Package
ZIP_NAME="keystone-native-macos.zip"
zip -j "$ZIP_NAME" "$BINARY_PATH"

# 3. Create Tag and Push
git tag "$TAG"
git push origin "$TAG"

# 4. GitHub Release
gh release create "$TAG" "$ZIP_NAME" \
    --title "Keystone Native $TAG" \
    --notes "### ✨ Native SwiftUI Release
- **Modern Interface**: Full SwiftUI desktop app.
- **Biometric First**: Native Touch ID integration.
- **Improved Performance**: Compiled Swift binary."

echo "✅ Release $TAG published to GitHub."
