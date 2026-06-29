# Movana PRD & Handoff

## Original Problem Statement
Build Movana, a production-ready Flutter Android/iOS OTT movie and series discovery app with premium dark UI, Firebase architecture, Google Authentication, Firestore, Storage, Cloud Functions, Analytics, Crashlytics, FCM, AdMob, TMDB API, watch providers, search, filters, watchlist, My Theatre, profile, admin dashboard, affiliate module, notifications, offline cache, pagination, documentation, and tests. The app must not stream content or scrape IMDb. Ratings must be swappable and currently rely on TMDB/demo data until a licensed provider is added.

## User Choices
- Build target: Flutter Android/iOS app structure.
- Firebase: Android and iOS Firebase config added; live Auth/Firestore/Storage/Messaging/Analytics/Crashlytics/Functions integration implemented.
- TMDB: live v4 token provided and stored server-side in `/app/backend/.env`; Cloud Functions should use `TMDB_ACCESS_TOKEN` environment variable.
- First deliverable: full architecture skeleton with key screens working first.
- Auth: live Anonymous guest mode and live Google Sign-In.

## Architecture Decisions
- Flutter + Riverpod + GoRouter + Material 3 dark-only theme.
- Clean modular structure under `lib/core`, `lib/data`, and `lib/features`.
- Firebase initialization uses `firebase_options.dart` generated from Android/iOS config values.
- TMDB calls move through server-side backend/Cloud Functions proxy, keeping secrets out of Flutter and browser clients.
- Ratings use a provider abstraction so TMDB can later be swapped with licensed IMDb-compatible data.
- Watchlist/My Theatre use live Firestore for signed-in Google users; anonymous guests are blocked from saving as required.
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
- `firebase_options.dart` added and Firebase Auth, Firestore, Storage, Cloud Messaging, Analytics, Crashlytics, and Functions services are live.
- iOS Google Sign-In callback configured via `CFBundleURLTypes` using `REVERSED_CLIENT_ID`.
- Firestore rules deny anonymous writes to `watchlist` and `watched`, matching the guest-mode product rule.
- Live TMDB connected for trending, popular, top-rated, now playing, upcoming, search, posters/backdrops, genres, ratings, runtime, overview, cast, trailers, and Indian watch providers where available.

## Validation
- Flutter/Dart SDK is not installed in the container, so runtime `flutter analyze` and `flutter test` could not run here.
- Static checks completed: Node function syntax valid, Firebase JSON/index valid, assets present, proxy hardening verified.
- Testing agent performed static QA and critical proxy issue was fixed.

## Prioritized Backlog
### P0
- Confirm Firebase Console providers are enabled: Google Sign-In, Anonymous Auth, Firestore, Storage, Analytics, Crashlytics, FCM, Functions, and AdMob.
- Add `TMDB_ACCESS_TOKEN` to deployed Firebase Cloud Functions environment before publishing mobile builds.
- Run `flutter pub get`, `flutter analyze`, and `flutter test` in a Flutter environment.
- Replace in-memory library state with Firestore-backed user watchlist/watched repositories.

### P1
- Implement true pagination, offline persistence, image cache controls, skeleton loaders, and real watch provider logos.
- Add Google Sign-In production flow and guest upgrade flow.
- Add Remote Config for ad IDs, affiliate banners, featured collections, and admin controls.
- Add notification topic subscriptions and campaign delivery.

### P2
- Add AI recommendation module, shareable image rendering, achievements engine, advanced analytics dashboards, and richer unit/widget tests.

## Preview Recovery Update
- Added a React/Vite web preview under `/app/frontend` so the Emergent preview URL has a runnable web app on port 3000.
- Added a minimal FastAPI preview health API under `/app/backend` so supervisor backend starts cleanly on port 8001.
- Restarted supervisor services and verified `http://localhost:3000` returns 200 and `/api/health` returns OK.
- The web preview mirrors Movana UI/flows for review; the primary production codebase remains Flutter Android/iOS.

## Vite Preview Host Fix
- Added `/app/frontend/vite.config.js` with `server.host = 0.0.0.0`, `server.port = 3000`, and `server.allowedHosts = true`.
- Added matching preview config and restarted the Vite supervisor process.
- Verified local and Emergent preview-style Host header requests return HTTP 200.

## UX Redesign Update
- Replaced the cluttered one-page discovery experience with the requested step flow: Login → OTT Selection → Platform Home → Genre Selection → Movie/Series List.
- Preview now uses square OTT cards with TMDB provider logos, large Movies/Series cards, poster-backed genre cards, Top Rated/All Time filters, and a three-tab bottom nav: Home, My Theatre, Watchlist.
- Movie cards now emphasize speed: poster, title, rating, year/runtime, overview, Already Watched toggle, and red Watchlist heart.
- Backend now supports provider logos, poster-backed genre cards, discover by provider/genre/type, global multi-search, runtime/provider hydration, and faster parallel genre loading.
- Flutter routes were refactored to `/ott`, `/platform-home`, `/genres`, `/movies`; login navigates to `/ott`; bottom navigation is reduced to Home/My Theatre/Watchlist.
- Flutter OTT cards use provider logo images; Flutter genre cards use poster-backed visuals; Flutter listing accepts platform/type/genre route params and functional rating/time menus.

## OTT/Details/Sharing Upgrade
- OTT selection now uses premium two-column provider cards with full TMDB logos, contained aspect ratio, selected glow, and checkmark.
- Home bottom navigation resets to OTT selection from any preview state; Flutter shell Home route also goes to `/ott`.
- Movie cards open a full TMDB details experience with backdrop, poster, metadata, Where to Watch, cast/crew, trailer, recommendations, similar titles, and image galleries.
- Movie list has three live filters: Rating, Release Date, and Language using TMDB `with_original_language`.
- Share Theatre now generates a Movana-branded PNG share card in preview and Flutter uses native `shareXFiles` image sharing.
- Genre artwork is unique: backend dynamically fetches/cache unique TMDB backdrops; Flutter fallback mapping now has unique backdrop URLs for all listed genres.
- Restored `/app/frontend/.env` with `REACT_APP_BACKEND_URL=/api` for preview/test URL contract.

## P0 Splash & JioHotstar Asset Update — 2026-06-29
- Replaced the cropped JioHotstar provider logo in both Flutter and React preview with the uploaded uncropped PNG asset at `assets/images/jiohotstar_logo.png` and `frontend/public/assets/images/jiohotstar_logo.png`.
- Added the new Flutter asset constant and registered it in `pubspec.yaml`; Flutter OTT cards now render the local JioHotstar asset with `BoxFit.contain`.
- Rebuilt the Movana splash as a cinematic Netflix-style sequence in Flutter and React preview: gold “M” mark, glow halo, light sweep, smooth zoom to black, and automatic transition to login.
- Validation completed: React lint passed, Vite production build passed, local backend/frontend health checks returned 200, screenshot smoke test confirmed splash transition and JioHotstar logo visibility. Flutter/Dart CLI is not installed in this container, so Flutter runtime analysis could not be executed; static build-safe checks passed.
