# Fintrack

A calm, private expense tracker built with Flutter and Firebase. Fintrack keeps the focus on the numbers that matter: a clear monthly view, a fast activity ledger, and a quiet interface that stays out of the way.

## Highlights

- Email/password and Google sign-in with Firebase Authentication.
- Real-time expenses stored per user in Cloud Firestore.
- Dashboard with monthly spend, daily pace, category mix, cumulative trend, and recent activity.
- Add, edit, and swipe-to-delete expenses with undo.
- Category filtering and date-grouped activity list.
- Responsive layout with a desktop sidebar and mobile bottom navigation.
- Light and dark themes with a restrained sage accent.
- Persisted currency setting with 30+ common currencies.
- Animated amounts, chart interactions, and tactile press states.

## Stack

- Flutter 3.50 / Dart 3.14
- Firebase Auth, Cloud Firestore, Google Sign-In
- Riverpod for state management
- go_router with a stateful navigation shell
- fl_chart for the category donut
- shared_preferences for local preferences
- Space Grotesk + Inter (bundled locally)
- `material_ui` for the Material widget set

## Project structure

```
lib/
  app.dart                  App shell, splash, and auth error state
  core/
    constants/              App name and expense categories
    currency/               Currency models and the selected-currency provider
    router/                 go_router configuration and auth redirects
    storage/                SharedPreferences provider
    theme/                  Palette, spacing, motion, themes
    utils/                  Formatters, category styles, error messages
    widgets/                Background, panels, brand mark, charts, nav
  features/
    auth/                   Login, signup, auth repository and providers
    dashboard/              Overview screen and dashboard cards
    expenses/               Activity list, form, model, repository, providers
    settings/               Profile, appearance, currency, and sign-out
```

## Getting started

1. Install Flutter 3.50 or newer and confirm the toolchain:

   ```bash
   flutter doctor
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a Firebase project and enable Email/Password and Google sign-in.
   - Create a Cloud Firestore database.
   - Add the FlutterFire configuration files for the platforms you target.
   - The app expects `lib/firebase_options.dart` plus the usual platform files (`android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, and web Firebase config).

4. Run the app:

   ```bash
   flutter run -d chrome
   ```

   Or target another device:

   ```bash
   flutter run -d windows
   flutter run -d android
   ```

## Firestore shape

Expenses are stored at:

```
users/{uid}/expenses/{expenseId}
```

Each document contains a positive `amount`, an allowed `category`, a Firestore timestamp `date`, and an optional `note` of at most 200 characters. The activity screen listens to this collection in real time.

## Verification

```bash
flutter analyze
flutter test
flutter build web
```

The project currently has no compile issues and the web release build succeeds. iOS builds require macOS and the iOS Firebase configuration file.

## Notes

- Fintrack currently tracks expenses only. Income, budgets, and profile editing are intentionally out of scope.
- Currency is selected in Settings and persisted locally with `shared_preferences`. Changing it updates the display symbol and number format only; existing amounts are not converted.
- The test account and sample expenses used during visual verification are temporary and should not be reused in production.
