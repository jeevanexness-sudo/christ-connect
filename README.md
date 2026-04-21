# Christ Connect ✝️

A complete Christian ecosystem Flutter app.

## Features
- 📖 Bible Reader (KJV/NIV/ESV with verse highlighting)
- 🎵 Worship (song list + karaoke lyrics)
- 📹 Media (sermons, services, events)
- 👥 Community (prayer, testimonies, devotionals)
- 🎓 Courses (learning with progress tracking)
- 💍 Matrimony (faith-first matchmaking)
- 👤 Profile (stats, settings)

## Structure
```
lib/
├── main.dart
├── core/           (app_colors, app_text_styles, app_theme, constants)
├── models/         (app_models)
├── data/           (mock_data)
├── navigation/     (main_navigation)
├── screens/        (home, bible, worship, media, community, courses, matrimony, profile)
└── widgets/        (shared widgets)
```

## Run
```bash
flutter pub get
flutter run
```

## Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```
