# Movana

Stop Scrolling. Start Watching.

Movana is a premium dark-themed Flutter app for discovering highly rated movies and series across OTT platforms. It is not a streaming app; it helps users decide what to watch and where it is available.

## Current Build

- Flutter Android/iOS project structure with Clean Architecture-inspired folders.
- Riverpod state management, Material 3 dark theme, premium splash/login/home/listing/details flows.
- Live Firebase Authentication with Google Sign-In and Anonymous guest sign-in.
- Watchlist and My Theatre state, share actions, statistics, admin dashboard skeleton.
- Firebase configuration: Android/iOS options, Firestore rules, Storage rules, Analytics, Crashlytics, FCM, and Cloud Functions in `asia-south1`.
- TMDB service layer routes through Firebase Cloud Functions with demo fallback data if TMDB server credentials are not configured.
- AdMob-ready service with official test ad IDs.

## Required Setup

1. Install Flutter latest stable.
2. Run `flutter pub get`.
3. Firebase config files:
   - Android is configured with `android/app/google-services.json` for package `app.movana.discovery`.
   - iOS is configured with `ios/Runner/GoogleService-Info.plist` for bundle `app.movana.discovery`.
4. Configure Firebase Auth, Firestore, Storage, Analytics, Crashlytics, Messaging, and AdMob in Firebase Console.
5. Store TMDB credentials securely for Cloud Functions using `TMDB_ACCESS_TOKEN`; do not place TMDB secrets in the client app.
6. Run the app with `flutter run`.

## Firebase Cloud Functions

Functions live in `/functions`:

- `refreshMovieMetadata`: scheduled every 24 hours to refresh trending metadata without duplicate records.
- `tmdbProxy`: secure proxy pattern for TMDB API calls.

## Notes

- IMDb scraping is intentionally not used. The app currently uses TMDB-style ratings and keeps the rating provider swappable.
- Demo content remains available as a fallback while live TMDB/Firestore data is populated.
