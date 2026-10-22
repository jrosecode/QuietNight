# TestFlight delivery

QuietNight is prepared for TestFlight with bundle ID `com.jrosecode.quietnight`, version `1.0.0`, build `1`, automatic signing, an App Store icon, and a privacy manifest.

## Required Apple setup

1. Install Xcode 26 or newer from the Mac App Store.
2. In Xcode, sign in under **Settings → Accounts** with the Apple ID that belongs to the paid Developer Program.
3. Create the app record in App Store Connect:
   - Name: `QuietNight`
   - Primary language: English
   - Bundle ID: `com.jrosecode.quietnight`
   - SKU: `quietnight-ios-001`
4. Open `QuietNight.xcodeproj`, select the QuietNight target, then **Signing & Capabilities**.
5. Select your paid development team. Keep “Automatically manage signing” enabled.
6. Archive using **Product → Archive**, then choose **Distribute App → App Store Connect → Upload**.
7. In App Store Connect → TestFlight, wait for processing, complete export-compliance questions, and add your Apple ID as an internal tester.
8. Install Apple’s TestFlight app on the iPhone and accept the invitation.

## Command-line upload

After Xcode and signing are configured, `scripts/upload-testflight.sh` archives and uploads using an App Store Connect API key. It requires:

- `APPLE_TEAM_ID`
- `ASC_KEY_ID`
- `ASC_ISSUER_ID`
- `~/.appstoreconnect/private_keys/AuthKey_$ASC_KEY_ID.p8`

Run:

```bash
./scripts/upload-testflight.sh
```

The script never stores credentials in the repository. Increase `CURRENT_PROJECT_VERSION` before every later upload.

## Current boundary

This Mac currently lacks full Xcode and has no Apple signing identity or App Store Connect key. The unsigned simulator build is verified in GitHub Actions; a signed TestFlight upload cannot be completed until the account prerequisites above are connected.
