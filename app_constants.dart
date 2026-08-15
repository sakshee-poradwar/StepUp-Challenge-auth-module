core/constants/app_constants.dart
// ============================================================
class AppConstants {
  AppConstants._();
  // ── Firestore Collections ─────────────────────────────────
  /// Main user profiles collection.
  /// INTEGRATION — Member 2 (Cloud Sync):
  ///   DailySteps sub-collection lives at:
  ///   users/{uid}/dailySteps/{dateKey}
  static const String kUsersCollection = 'users';
  /// Sub-collection for daily step records.
  static const String kDailyStepsCollection = 'dailySteps';
  // ── Storage Paths ─────────────────────────────────────────
  /// Firebase Storage path for user avatars.
  static const String kAvatarsStoragePath = 'avatars';
  // ── Shared Preferences Keys ───────────────────────────────
  static const String kOnboardingCompleteKey = 'onboarding_complete';
  static const String kThemeModeKey = 'theme_mode';
  // ── Default Values ────────────────────────────────────────
  static const int kDefaultDailyStepGoal = 10000;
  static const int kMinDailyStepGoal = 1000;
  static const int kMaxDailyStepGoal = 50000;
  // ── Animation Durations ───────────────────────────────────
  static const Duration kFastAnimation = Duration(milliseconds: 200);
  static const Duration kNormalAnimation = Duration(milliseconds: 350);
  static const Duration kSlowAnimation = Duration(milliseconds: 600);
}
