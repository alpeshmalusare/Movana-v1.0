# Movana

Stop Scrolling. Start Watching.

Movana is a premium dark-themed Flutter app for discovering highly rated movies and series across OTT platforms. It is not a streaming app; it helps users decide what to watch and where it is available.

## Current Build

- Flutter Android/iOS project structure with Clean Architecture-inspired folders.
- Riverpod state management, Material 3 dark theme, premium splash/login/home/listing/details flows.
- Guest mode and mock Google profile flow for development.
- Watchlist and My Theatre state, share actions, statistics, admin dashboard skeleton.
- Firebase-ready configuration: Firestore rules, Storage rules, Cloud Functions scheduler/proxy structure.
- TMDB service layer with demo fallback data until the TMDB key and Firebase project are configured.
- AdMob-ready service with official test ad IDs.

## Required Setup

1. Install Flutter latest stable.
2. Run `flutter pub get`.
3. Add Firebase config files:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. Configure Firebase Auth, Firestore, Storage, Analytics, Crashlytics, Messaging, and AdMob in Firebase Console.
5. Store TMDB credentials securely for Cloud Functions using `TMDB_ACCESS_TOKEN`; do not place TMDB secrets in the client app.
6. Run the app with `flutter run`.

## Firebase Cloud Functions

Functions live in `/functions`:

- `refreshMovieMetadata`: scheduled every 24 hours to refresh trending metadata without duplicate records.
- `tmdbProxy`: secure proxy pattern for TMDB API calls.

## Notes

- IMDb scraping is intentionally not used. The app currently uses TMDB-style ratings and keeps the rating provider swappable.
- Firebase integration is architecture-ready with placeholders because live Firebase credentials were not provided yet.
- Demo content is included so the core user experience works immediately.
