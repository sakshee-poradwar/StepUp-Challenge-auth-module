import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepauth/core/theme/app_theme.dart';
import 'package:stepauth/data/repositories/auth_repository.dart';
import 'package:stepauth/presentation/providers/auth_provider.dart';
import 'package:stepauth/presentation/widgets/loading_overlay.dart';
import 'package:stepauth/presentation/widgets/social_auth_button.dart';

enum AuthMode { signIn, signUp }
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.initialMode = AuthMode.signUp});
 
  final AuthMode initialMode;
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AuthMode _mode;
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _obscurePassword = true;
  late final AnimationController _bgCtrl;
  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _bgCtrl = AnimationController(vsync: this, duration: 8.seconds)..repeat();
  }
  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }
 
  Future<void> _submitEmailForm() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(authNotifierProvider.notifier);
    if (_mode == AuthMode.signIn) {
      await notifier.signInWithEmail(_emailCtrl.text, _passwordCtrl.text);
    } else {
      await notifier.signUpWithEmail(
        _emailCtrl.text,
        _passwordCtrl.text,
        _nameCtrl.text,
      );
    }
   
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
   
    ref.listen(authNotifierProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) {
          final msg = e is AuthException ? e.message : 'Sign-in failed.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: AppTheme.error,
            ),
          );
        },
      );
    });
    return LoadingOverlay(
      isLoading: authState.isLoading,
      child: Scaffold(
        body: _buildBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildGlassCard(),
                  const SizedBox(height: 24),
                  _buildSocialButtons(),
                  const SizedBox(height: 32),
                  _buildModeToggle(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
          child: const Text(
            'StepSync',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
        const SizedBox(height: 6),
        Text(
          _mode == AuthMode.signIn
              ? 'Welcome back, champion 👋'
              : 'Create your account',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.onSurfaceMuted,
              ),
        ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
      ],
    );
  }
  
  Widget _buildBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Stack(
        children: [
          
          Positioned(
            top: -80,
            right: -60,
            child: AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) => Opacity(
                opacity: 0.35,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppTheme.primary, Colors.transparent],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: Opacity(
              opacity: 0.2,
              child: Container(
                width: 220,
                height: 220,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppTheme.accent, Colors.transparent],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
 
  Widget _buildGlassCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: glassDecoration(borderRadius: 24),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
               
                AnimatedSize(
                  duration: AppTheme.kNormalAnimation,
                  curve: Curves.easeInOut,
                  child: _mode == AuthMode.signUp
                      ? Column(
                          children: [
                            _buildTextField(
                              controller: _nameCtrl,
                              label: 'Full Name',
                              icon: Icons.person_outline,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Enter your name'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                
                _buildTextField(
                  controller: _emailCtrl,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || !v.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                _buildTextField(
                  controller: _passwordCtrl,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.onSurfaceMuted,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => v == null || v.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                if (_mode == AuthMode.signIn) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                       
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: AppTheme.primaryLight,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                
                _GradientSubmitButton(
                  label: _mode == AuthMode.signIn ? 'Sign In' : 'Create Account',
                  onTap: _submitEmailForm,
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 200.ms)
        .fadeIn();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppTheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffixIcon,
      ),
    );
  }
 
  Widget _buildSocialButtons() {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 13),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SocialAuthButton(
                label: 'Google',
                icon: Icons.g_mobiledata_rounded,
                onTap: () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SocialAuthButton(
                label: 'Apple',
                icon: Icons.apple,
                onTap: () => ref.read(authNotifierProvider.notifier).signInWithApple(),
              ),
            ),
          ],
        ),
      ],
    ).animate(delay: 350.ms).fadeIn();
  }
 
  Widget _buildModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _mode == AuthMode.signIn
              ? "Don't have an account? "
              : 'Already have an account? ',
          style: const TextStyle(color: AppTheme.onSurfaceMuted, fontSize: 14),
        ),
        GestureDetector(
          onTap: () => setState(() {
            _mode =
                _mode == AuthMode.signIn ? AuthMode.signUp : AuthMode.signIn;
            _formKey.currentState?.reset();
          }),
          child: Text(
            _mode == AuthMode.signIn ? 'Sign Up' : 'Sign In',
            style: const TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ).animate(delay: 400.ms).fadeIn();
  }
}

class _GradientSubmitButton extends StatelessWidget {
  const _GradientSubmitButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x556C63FF),
              blurRadius: 20,
              offset: Offset(0, 6),
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
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
