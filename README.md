# StepUp-Challenge-auth-module
# Flutter Auth Module — Step Tracking App
## Project Structure
```
stepauth/
├── pubspec.yaml
├── android/
│   └── app/google-services.json  (placeholder note)
├── ios/
│   └── GoogleService-Info.plist  (placeholder note)
└── lib/
    ├── main.dart                         # Firebase init + ProviderScope
    ├── firebase_options.dart             # FlutterFire CLI generated stub
    │
    ├── core/
    │   ├── constants/app_constants.dart
    │   └── theme/app_theme.dart
    │
    ├── data/
    │   └── repositories/
    │       └── auth_repository.dart      # AuthRepository impl
    │
    ├── domain/
    │   ├── entities/user_profile.dart    # UserProfile model
    │   └── usecases/
    │       ├── sign_in_google.dart
    │       ├── sign_in_apple.dart
    │       ├── sign_in_email.dart
    │       ├── sign_up_email.dart
    │       └── sign_out.dart
    │
    └── presentation/
        ├── providers/
        │   ├── auth_provider.dart        # StreamProvider<User?>
        │   └── profile_provider.dart     # StateNotifier for profile
        ├── screens/
        │   ├── auth_gate.dart            # Routing widget
        │   ├── onboarding/
        │   │   ├── welcome_screen.dart
        │   │   ├── login_screen.dart
        │   │   └── setup_profile_screen.dart
        │   ├── dashboard/
        │   │   └── dashboard_screen.dart
        │   └── profile/
        │       └── profile_screen.dart
        └── widgets/
            ├── social_auth_button.dart
            └── loading_overlay.dart
```
