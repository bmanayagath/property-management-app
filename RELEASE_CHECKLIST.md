# VillaBooks Production Release Checklist

## iOS Release

- Confirm `PRODUCT_BUNDLE_IDENTIFIER` in `ios/Runner.xcodeproj/project.pbxproj`.
  Current value: `com.example.villabooks`.
- Confirm `ios/Runner/GoogleService-Info.plist` uses the same bundle id.
  Current value: `com.example.villabooks`.
- Replace the example bundle id with the final App Store bundle id in both
  Apple Developer and Firebase before uploading a production build.
- Confirm Apple signing team and automatic/manual signing in Xcode.
- Confirm `pubspec.yaml` `version` and build number before each upload.
- Confirm app icon includes the required 1024x1024 marketing icon.
- Confirm launch screen renders correctly on iPhone and iPad sizes.
- Run:

```sh
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build ipa --release
```

## App Store Submission

- Production app name: `VillaBooks`.
- Add official support URL.
- Add official privacy policy URL.
- Add official terms URL if separate from privacy policy.
- Prepare 6.9-inch iPhone screenshots.
- Prepare 6.5-inch iPhone screenshots if required by App Store Connect.
- Prepare iPad screenshots if iPad support remains enabled.
- Suggested subtitle: `Rental income and expense manager`.
- Suggested keywords: `villa,rent,landlord,property,income,expense,rooms`.
- Suggested age rating: `4+`, assuming no unrestricted web content or user
  generated public content is added.
- Complete App Privacy labels for account identifiers, financial records, and
  diagnostics if collected.

## Production Data Setup

- Enable Firebase Auth email/password sign-in.
- Create Firebase Auth accounts for each production user.
- Create matching Firestore `users/{uid}` profiles with:

```json
{
  "username": "user@example.com",
  "email": "user@example.com",
  "role": "Admin",
  "isActive": true,
  "isDeleted": false
}
```

- Deploy `firestore.rules`.
- Create the first admin profile from the Firebase console before release.
- Do not store user passwords in Firestore or SharedPreferences.

## Manual QA

- Fresh install with empty Firestore.
- Fresh install with populated Firestore.
- Login, logout, app restart, and session restore.
- Admin, Contributor, and Reader permission checks.
- Offline add income/expense, reconnect, and verify sync.
- Two-device villa, room, income, and expense sync.
- Soft delete villa and verify child rooms/transactions are excluded.
- Soft delete room and verify linked transactions are excluded.
- Run orphan cleanup and verify deleted records sync as soft deletes.
- Firestore reset and local app recovery.
- Dashboard recalculation after each sync/delete/offline scenario.
