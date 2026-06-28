# Movana PRD & Handoff

## Original Problem Statement
Build Movana, a production-ready Flutter Android/iOS OTT movie and series discovery app with premium dark UI, Firebase architecture, Google Authentication, Firestore, Storage, Cloud Functions, Analytics, Crashlytics, FCM, AdMob, TMDB API, watch providers, search, filters, watchlist, My Theatre, profile, admin dashboard, affiliate module, notifications, offline cache, pagination, documentation, and tests. The app must not stream content or scrape IMDb. Ratings must be swappable and currently rely on TMDB/demo data until a licensed provider is added.

## User Choices
- Build target: Flutter Android/iOS app structure.
- Firebase: Firebase-ready architecture with placeholders.
- TMDB: user will provide API key later.
- First deliverable: full architecture skeleton with key screens working first.
- Auth: guest mode fully and mock signed-in profile for demo.

## Architecture Decisions
- Flutter + Riverpod + GoRouter + Material 3 dark-only theme.
- Clean modular structure under `lib/core`, `lib/data`, and `lib/features`.
- Firebase initialization is placeholder-safe until native config files are added.
- TMDB calls are designed to move through hardened Cloud Functions proxy, keeping secrets off the client.
- Ratings use a provider abstraction so TMDB can later be swapped with licensed IMDb-compatible data.
- Watchlist/My Theatre currently use in-memory Riverpod state for demo; Firestore schema/rules are ready.
- AdMob uses official test IDs and should later read production IDs from Firebase Remote Config.

## Implemented
- Splash screen with uploaded Movana logo, fade/scale animation, 2-second login transition.
- Login screen with mock Google profile and guest mode.
- Home discovery with instant search, OTT multi-select, content type toggle, genre grid, rating/year/language filters.
- Movie/series listing cards with poster, metadata, ratings, providers/theatre status, watched/watchlist buttons.
- Details page with backdrop, overview, director/writer/cast/production, trailer/share/actions, similar/reviews sections.
- Watchlist, My Theatre statistics/share card, Profile, and Admin Dashboard skeleton.
- Firebase rules, Storage rules, Firestore index, Functions scheduled refresh and hardened TMDB proxy.
- Affiliate, analytics, notification, offline cache, AdMob, rating provider, and Firestore schema service skeletons.
- README, native Android/iOS placeholders, test credentials doc, and smoke test.
- Android Firebase configuration added at `android/app/google-services.json` for package `app.movana.discovery` and Firebase project `movana-f578b`.
- iOS Firebase configuration added at `ios/Runner/GoogleService-Info.plist` for bundle `app.movana.discovery` and Firebase project `movana-f578b`.

## Validation
- Flutter/Dart SDK is not installed in the container, so runtime `flutter analyze` and `flutter test` could not run here.
- Static checks completed: Node function syntax valid, Firebase JSON/index valid, assets present, proxy hardening verified.
- Testing agent performed static QA and critical proxy issue was fixed.

## Prioritized Backlog
### P0
- Enable Auth, Firestore, Storage, Analytics, Crashlytics, FCM, and AdMob in Firebase Console.
- Add TMDB access token to Cloud Functions environment and connect Flutter service to proxy.
- Run `flutter pub get`, `flutter analyze`, and `flutter test` in a Flutter environment.
- Replace in-memory library state with Firestore-backed user watchlist/watched repositories.

### P1
- Implement true pagination, offline persistence, image cache controls, skeleton loaders, and real watch provider logos.
- Add Google Sign-In production flow and guest upgrade flow.
- Add Remote Config for ad IDs, affiliate banners, featured collections, and admin controls.
- Add notification topic subscriptions and campaign delivery.

### P2
- Add AI recommendation module, shareable image rendering, achievements engine, advanced analytics dashboards, and richer unit/widget tests.
