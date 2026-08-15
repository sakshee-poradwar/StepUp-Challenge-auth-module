import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepauth/presentation/providers/auth_provider.dart';
import 'package:stepauth/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:stepauth/presentation/screens/onboarding/login_screen.dart';
import 'package:stepauth/presentation/screens/onboarding/setup_profile_screen.dart';
import 'package:stepauth/presentation/screens/onboarding/welcome_screen.dart';
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
     
      loading: () => const WelcomeScreen(),
      
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text(
            'Something went wrong.\n$err',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      
      data: (user) {
        if (user == null) {
          
          return const LoginScreen();
        }
        
        final profileAsync = ref.watch(userProfileStreamProvider);
        return profileAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => const DashboardScreen(),
          data: (profile) {
            if (profile == null || !profile.isProfileComplete) {
              return const SetupProfileScreen();
            }
            return const DashboardScreen();
          },
        );
      },
    );
  }
}
