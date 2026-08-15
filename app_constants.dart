core/constants/app_constants.dart

class AppConstants {
  AppConstants._();
  
  static const String kUsersCollection = 'users';
  
  static const String kDailyStepsCollection = 'dailySteps';
  
  static const String kAvatarsStoragePath = 'avatars';
  
  static const String kOnboardingCompleteKey = 'onboarding_complete';
  static const String kThemeModeKey = 'theme_mode';
  
  static const int kDefaultDailyStepGoal = 10000;
  static const int kMinDailyStepGoal = 1000;
  static const int kMaxDailyStepGoal = 50000;
  
  static const Duration kFastAnimation = Duration(milliseconds: 200);
  static const Duration kNormalAnimation = Duration(milliseconds: 350);
  static const Duration kSlowAnimation = Duration(milliseconds: 600);
}
