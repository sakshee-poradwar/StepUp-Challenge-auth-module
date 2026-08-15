import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stepauth/data/repositories/auth_repository.dart';
import 'package:stepauth/domain/entities/user_profile.dart';
import 'package:stepauth/presentation/providers/auth_provider.dart';

class ProfileEditState {
  const ProfileEditState({
    this.displayName = '',
    this.dailyStepGoal = 10000,
    this.avatarUrl,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });
  final String displayName;
  final int dailyStepGoal;
  final String? avatarUrl;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  ProfileEditState copyWith({
    String? displayName,
    int? dailyStepGoal,
    String? avatarUrl,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return ProfileEditState(
      displayName: displayName ?? this.displayName,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class ProfileEditNotifier extends StateNotifier<ProfileEditState> {
  ProfileEditNotifier(this._repository, this._ref, UserProfile? initial)
      : super(ProfileEditState(
          displayName: initial?.displayName ?? '',
          dailyStepGoal: initial?.dailyStepGoal ?? 10000,
          avatarUrl: initial?.avatarUrl,
        ));
  final AuthRepository _repository;
  final Ref _ref;
  final _imagePicker = ImagePicker();
  void updateDisplayName(String name) {
    state = state.copyWith(displayName: name);
  }
  void updateDailyStepGoal(int goal) {
    state = state.copyWith(dailyStepGoal: goal);
  }
  
  Future<void> pickAndUploadAvatar() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (pickedFile == null) return;
    state = state.copyWith(isLoading: true);
    try {
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to upload avatar.',
      );
    }
  }
  /// Saves the edited profile fields to Firestore.
  Future<void> saveProfile() async {
    final uid = _ref.read(currentUserIdProvider);
    if (uid == null) return;
    state = state.copyWith(isLoading: true);
    try {
      await _repository.updateProfile(
        uid: uid,
        displayName: state.displayName,
        avatarUrl: state.avatarUrl,
        dailyStepGoal: state.dailyStepGoal,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Profile updated!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save profile.',
      );
    }
  }
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

final profileEditProvider =
    StateNotifierProvider<ProfileEditNotifier, ProfileEditState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final profile = ref.watch(userProfileStreamProvider).valueOrNull;
  return ProfileEditNotifier(repo, ref, profile);
});
