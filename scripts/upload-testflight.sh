#!/usr/bin/env bash
set -euo pipefail

: "${APPLE_TEAM_ID:?Set APPLE_TEAM_ID}"
: "${ASC_KEY_ID:?Set ASC_KEY_ID}"
: "${ASC_ISSUER_ID:?Set ASC_ISSUER_ID}"

KEY="$HOME/.appstoreconnect/private_keys/AuthKey_${ASC_KEY_ID}.p8"
[[ -f "$KEY" ]] || { echo "Missing App Store Connect key: $KEY" >&2; exit 1; }
command -v xcodegen >/dev/null || { echo "Install XcodeGen: brew install xcodegen" >&2; exit 1; }
xcodebuild -version

xcodegen generate
rm -rf build/QuietNight.xcarchive build/export

xcodebuild \
  -project QuietNight.xcodeproj \
  -scheme QuietNight \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath build/QuietNight.xcarchive \
  DEVELOPMENT_TEAM="$APPLE_TEAM_ID" \
  -allowProvisioningUpdates \
  archive

cat > build/ExportOptions.plist <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>method</key><string>app-store-connect</string>
<key>teamID</key><string>${APPLE_TEAM_ID}</string>
<key>signingStyle</key><string>automatic</string>
<key>uploadSymbols</key><true/>
</dict></plist>
PLIST

xcodebuild -exportArchive \
  -archivePath build/QuietNight.xcarchive \
  -exportPath build/export \
  -exportOptionsPlist build/ExportOptions.plist \
  -allowProvisioningUpdates

IPA="$(find build/export -name '*.ipa' -print -quit)"
[[ -n "$IPA" ]] || { echo "No IPA produced" >&2; exit 1; }

xcrun altool --upload-app --type ios --file "$IPA" \
  --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"

echo "Upload accepted. Check App Store Connect → TestFlight for processing."
