# iOS Firebase Setup

`GoogleService-Info.plist` has been placed in the correct Flutter iOS directory:

`ios/Runner/GoogleService-Info.plist`

Verified Firebase values:

- Bundle Identifier: `app.movana.discovery`
- Firebase Project: `movana-f578b`
- Google Sign-In URL scheme is configured in `ios/Runner/Info.plist` using `REVERSED_CLIENT_ID`.

Run `flutter pub get`, then open the iOS project in Xcode and ensure `GoogleService-Info.plist` is included in the Runner target if Xcode does not add it automatically.