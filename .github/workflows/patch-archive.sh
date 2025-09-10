#!/usr/bin/env bash
set -euo pipefail

# ==== Chỉnh đường dẫn project & scheme ====
PROJECT_PATH="mediapipe-samples/examples/llm_inference/ios/InferenceExample.xcodeproj"
SCHEME="InferenceExample"
CONFIG="Release"
ARCHIVE_PATH="${RUNNER_TEMP}/build/App.xcarchive"
# ==========================================

if [ ! -e "$PROJECT_PATH" ]; then
  echo "❌ PROJECT_PATH='$PROJECT_PATH' NOT FOUND"
  echo "Hint: chạy 'find . -name \"*.xcodeproj\"' để kiểm tra."
  exit 66
fi

echo "📦 Archiving project: $PROJECT_PATH (scheme: $SCHEME, config: $CONFIG)"

EXTRA_SIGN_ARGS=()
if [ "${TEAM_ID:-}" != "" ]; then
  EXTRA_SIGN_ARGS+=(DEVELOPMENT_TEAM="$TEAM_ID")
fi
if [ "${BUNDLE_ID:-}" != "" ]; then
  EXTRA_SIGN_ARGS+=(PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID")
fi
if [ "${PROFILE_SPECIFIER:-}" != "" ]; then
  EXTRA_SIGN_ARGS+=(CODE_SIGN_STYLE=Manual PROVISIONING_PROFILE_SPECIFIER="$PROFILE_SPECIFIER")
fi

set -x
xcodebuild archive \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -sdk iphoneos \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  "${EXTRA_SIGN_ARGS[@]}" \
  -allowProvisioningUpdates \
| { command -v xcpretty >/dev/null 2>&1 && xcpretty || cat; }
set +x

echo "✅ Archive xong: $ARCHIVE_PATH"
