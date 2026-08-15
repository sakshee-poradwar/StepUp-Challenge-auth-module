
stepauth/
├── pubspec.yaml
├── android/
│   └── app/google-services.json  (placeholder note)
├── ios/
│   └── GoogleService-Info.plist  (placeholder note)
└── lib/
    ├── main.dart                        
    ├── firebase_options.dart             
    │
    ├── core/
    │   ├── constants/app_constants.dart
    │   └── theme/app_theme.dart
    │
    ├── data/
    │   └── repositories/
    │       └── auth_repository.dart      
    │
    ├── domain/
    │   ├── entities/user_profile.dart    
    │   └── usecases/
    │       ├── sign_in_google.dart
    │       ├── sign_in_apple.dart
    │       ├── sign_in_email.dart
    │       ├── sign_up_email.dart
    │       └── sign_out.dart
    │
    └── presentation/
        ├── providers/
        │   ├── auth_provider.dart        
        │   └── profile_provider.dart     
        ├── screens/
        │   ├── auth_gate.dart            
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

