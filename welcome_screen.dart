
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:stepauth/core/theme/app_theme.dart';
import 'package:stepauth/presentation/screens/onboarding/login_screen.dart';
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
               
                _GlowingStepBadge(size: size.width * 0.55)
                    .animate()
                    .scale(
                      duration: 700.ms,
                      curve: Curves.elasticOut,
                    )
                    .fadeIn(),
                const SizedBox(height: 40),
                
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: Text(
                    'StepSync',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(color: Colors.white),
                  ),
                )
                    .animate(delay: 200.ms)
                    .slideY(begin: 0.3, end: 0, duration: 500.ms)
                    .fadeIn(),
                const SizedBox(height: 12),
                Text(
                  'Move together.\nAchieve more.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.onSurfaceMuted,
                        height: 1.5,
                      ),
                )
                    .animate(delay: 350.ms)
                    .slideY(begin: 0.3, end: 0, duration: 500.ms)
                    .fadeIn(),
                const Spacer(flex: 3),
                
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: const [
                    _FeaturePill(icon: Icons.directions_walk, label: 'Track Steps'),
                    _FeaturePill(icon: Icons.leaderboard, label: 'Compete'),
                    _FeaturePill(icon: Icons.cloud_sync, label: 'Sync Cloud'),
                    _FeaturePill(icon: Icons.people, label: 'Friends'),
                  ],
                )
                    .animate(delay: 450.ms)
                    .fadeIn(duration: 500.ms),
                const Spacer(flex: 2),
                
                _GradientButton(
                  label: 'Get Started',
                  onTap: () => Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const LoginScreen(),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: AppTheme.kNormalAnimation,
                    ),
                  ),
                )
                    .animate(delay: 600.ms)
                    .slideY(begin: 0.5, end: 0, duration: 500.ms)
                    .fadeIn(),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(initialMode: AuthMode.signIn),
                    ),
                  ),
                  child: Text(
                    'I already have an account',
                    style: TextStyle(
                      color: AppTheme.onSurfaceMuted,
                      fontSize: 14,
                    ),
                  ),
                ).animate(delay: 650.ms).fadeIn(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowingStepBadge extends StatelessWidget {
  const _GlowingStepBadge({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0x336C63FF), Color(0x006C63FF)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x556C63FF),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.78,
          height: size * 0.78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_walk, size: 52, color: Colors.white),
              const SizedBox(height: 4),
              Text(
                '10,247',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
              Text(
                'steps today',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: glassDecoration(borderRadius: 100),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x556C63FF),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
