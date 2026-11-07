# Let Me Cook

A Flutter recipe app. Recipes, fridge matching, accounts and saved recipes come
from the Let Me Cook API (`../let_me_cook_api`).

## Running

Start the API first (`npm run dev` in `let_me_cook_api`), then:

```bash
flutter run
```

The app finds the API at:

| Where the app runs | API address |
|---|---|
| Android emulator | `http://10.0.2.2:3000` (default) |
| iOS simulator, macOS, web | `http://localhost:3000` (default) |
| Real phone on your Wi-Fi | pass your computer's address, e.g. `flutter run --dart-define=API_URL=http://192.168.0.8:3000` |

The same `--dart-define` works for `flutter build apk`.

## Tests

```bash
flutter test                                    # widget tests, against a fake API
flutter test test/live_api_test.dart --dart-define=API_URL=http://localhost:3000
```

## Layout

```
lib/data/api/          HTTP client, base URL, login token storage
lib/data/              models and RecipeRepository (all API calls)
lib/features/          one folder per screen area (home, fridge, saved, auth, profile)
test/support/          fake API and sample data for tests
```

## Before release

Android allows plain `http://` (`usesCleartextTraffic` in `AndroidManifest.xml`) and
iOS allows local-network HTTP so the dev API works. Remove both once the API is on HTTPS.
