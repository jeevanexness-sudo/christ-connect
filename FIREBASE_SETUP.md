# 🔥 Firebase Setup Guide — Christ Connect

Follow these steps EXACTLY before running the app.

---

## STEP 1 — Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click **"Add project"**
3. Name it: `christ-connect`
4. Disable Google Analytics (optional) → **Create project**

---

## STEP 2 — Add Android App to Firebase

1. In Firebase Console → click **Android icon** (</> or Android)
2. Fill in:
   - **Android package name:** `com.example.christ_connect`
   - **App nickname:** Christ Connect
   - **Debug signing cert SHA-1:** (skip for now)
3. Click **Register app**
4. Download `google-services.json`
5. Place it in: `android/app/google-services.json`

---

## STEP 3 — Enable Authentication Methods

1. Firebase Console → **Authentication** → **Get started**
2. **Sign-in method** tab → Enable:
   - ✅ **Google** → Enable → Save
   - ✅ **Phone** → Enable → Save

---

## STEP 4 — Create Firestore Database

1. Firebase Console → **Firestore Database** → **Create database**
2. Choose: **Start in test mode** (for development)
3. Select your region → **Done**
4. Go to **Rules** tab → paste this:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

5. Click **Publish**

---

## STEP 5 — Add google-services.json to GitHub

If using GitHub Actions for CI/CD:

1. Open your `google-services.json` file
2. Copy the entire content
3. Go to GitHub repo → **Settings** → **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Name: `GOOGLE_SERVICES_JSON`
6. Value: paste the entire JSON content
7. Click **Add secret**

Then update `.github/workflows/build_apk.yml` — replace the placeholder step with:

```yaml
- name: Create google-services.json from secret
  run: echo '${{ secrets.GOOGLE_SERVICES_JSON }}' > android/app/google-services.json
```

---

## STEP 6 — Run the App

```bash
flutter pub get
flutter run
```

---

## Folder Structure (lib/)

```
lib/
├── main.dart                    ← Firebase init + AuthWrapper
├── core/
│   ├── app_colors.dart          ← All colors
│   ├── app_text_styles.dart     ← All text styles
│   ├── app_theme.dart           ← Dark + Light theme
│   └── constants.dart           ← K.pad, K.tabXxx
├── models/
│   ├── user_model.dart          ← UserModel (Firestore ↔ Dart)
│   └── app_models.dart          ← Song, Course, etc.
├── services/
│   ├── auth_service.dart        ← Google + Phone auth logic
│   └── firestore_service.dart   ← Firestore CRUD operations
├── providers/
│   └── auth_provider.dart       ← State management (ChangeNotifier)
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart    ← Login page (Google + Phone)
│   │   ├── phone_auth_screen.dart ← Phone number input
│   │   └── otp_screen.dart      ← OTP verification (6 boxes)
│   ├── home/    bible/    worship/    media/
│   ├── community/    courses/    matrimony/
│   └── profile/                 ← Shows real user data from Firestore
├── navigation/
│   └── main_navigation.dart     ← Bottom nav (5 tabs)
└── widgets/
    └── widgets.dart             ← All shared widgets (barrel file)
```

---

## Auth Flow

```
App opens
    ↓
AuthWrapper checks Firebase auth state
    ↓
Not logged in → LoginScreen
    ├── Google Sign-In → save to Firestore → HomeScreen
    └── Phone Number → OTP Screen → save to Firestore → HomeScreen
    ↓
Logged in → MainNavigation (Home/Bible/Worship/Media/Profile)
    ↓
Profile Screen shows real name, email, photo from Firestore
    ↓
Sign Out → back to LoginScreen
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `google-services.json not found` | Place file in `android/app/` |
| Google sign-in fails | Add SHA-1 in Firebase Console → Project settings |
| Phone OTP not sending | Enable Phone auth in Firebase Console |
| Firestore permission denied | Check Firestore Rules (Step 4) |
