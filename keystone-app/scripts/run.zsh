#!/usr/bin/env zsh
set -e

echo "🔨 Ensuring latest build..."
swift build -c release

echo "🚀 Launching Keystone Native (GUI)..."
echo "ℹ️  The terminal will remain active while the app is running."
echo "ℹ️  You can close the app with Cmd+Q to return to the shell."

# Run the release binary
$(swift build -c release --show-bin-path)/Keystone
