import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepauth/core/constants/app_constants.dart';
import 'package:stepauth/core/theme/app_theme.dart';
import 'package:stepauth/presentation/providers/auth_provider.dart';
import 'package:stepauth/presentation/providers/profile_provider.dart';
import 'package:stepauth/presentation/widgets/loading_overlay.dart';
class SetupProfileScreen extends ConsumerStatefulWidget {
  const SetupProfileScreen({super.key});
  @override
  ConsumerState<SetupProfileScreen> createState() => _SetupProfileScreenState();
}
class _SetupProfileScreenState extends ConsumerState<SetupProfileScreen> {
  final _nameCtrl = TextEditingController();
  int _stepGoal = AppConstants.kDefaultDailyStepGoal;
  int _step = 0; // 0 = name, 1 = step goal
  @override
  void initState() {
    super.initState();
    
    final user = ref.read(currentUserProvider);
    if (user?.displayName != null) {
      _nameCtrl.text = user!.displayName!;
    }
  }
  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }
  Future<void> _finish() async {
    final notifier = ref.read(profileEditProvider.notifier);
    notifier.updateDisplayName(_nameCtrl.text);
    notifier.updateDailyStepGoal(_stepGoal);
    await notifier.saveProfile();
    final uid = ref.read(currentUserIdProvider);
    if (uid != null) {
      await ref.read(authRepositoryProvider).markProfileComplete(uid);
    }
  }
  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileEditProvider);
    return LoadingOverlay(
      isLoading: profileState.isLoading,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  _buildProgressIndicator(),
                  const SizedBox(height: 40),
                  AnimatedSwitcher(
                    duration: AppTheme.kNormalAnimation,
                    transitionBuilder: (child, animation) => SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: _step == 0
                        ? _NameStep(controller: _nameCtrl, key: const ValueKey(0))
                        : _StepGoalStep(
                            key: const ValueKey(1),
                            value: _stepGoal,
                            onChanged: (v) => setState(() => _stepGoal = v),
                          ),
                  ),
                  const Spacer(),
                  _buildNavButtons(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildProgressIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set up your profile',
          style: Theme.of(context).textTheme.headlineMedium,
        ).animate().fadeIn().slideY(begin: -0.2, end: 0),
        const SizedBox(height: 16),
        Row(
          children: List.generate(2, (i) {
            final isActive = i <= _step;
            return Expanded(
              child: AnimatedContainer(
                duration: AppTheme.kNormalAnimation,
                height: 4,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: isActive ? AppTheme.primaryGradient : null,
                  color: isActive ? null : AppTheme.divider,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
  Widget _buildNavButtons() {
    return Row(
      children: [
        if (_step > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: () => setState(() => _step--),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.onSurface,
                side: const BorderSide(color: AppTheme.divider),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Back'),
            ),
          ),
        if (_step > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              if (_step == 0) {
                if (_nameCtrl.text.trim().isEmpty) return;
                setState(() => _step = 1);
              } else {
                _finish();
              }
            },
            child: Container(
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
                _step == 0 ? 'Continue' : 'Start Stepping!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NameStep extends StatelessWidget {
  const _NameStep({super.key, required this.controller});
  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What should we\ncall you?',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 32,
                height: 1.2,
              ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
        const SizedBox(height: 8),
        Text(
          'This name will appear on the leaderboard.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppTheme.onSurfaceMuted),
        ).animate(delay: 100.ms).fadeIn(),
        const SizedBox(height: 32),
        TextFormField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.onSurface, fontSize: 18),
          decoration: const InputDecoration(
            labelText: 'Display Name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
      ],
    );
  }
}

class _StepGoalStep extends StatelessWidget {
  const _StepGoalStep({super.key, required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Set your daily\nstep goal',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 32,
                height: 1.2,
              ),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 8),
        Text(
          'The WHO recommends 10,000 steps per day.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppTheme.onSurfaceMuted),
        ).animate(delay: 100.ms).fadeIn(),
        const SizedBox(height: 40),
        
        Center(
          child: ShaderMask(
            shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
            child: Text(
              value.toString().replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (m) => '${m[1]},',
                  ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.w700,
                letterSpacing: -2,
              ),
            ),
          ).animate(delay: 150.ms).scale(begin: const Offset(0.8, 0.8)),
        ),
        Center(
          child: Text(
            'steps / day',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppTheme.onSurfaceMuted),
          ),
        ),
        const SizedBox(height: 32),
        
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primary,
            inactiveTrackColor: AppTheme.divider,
            thumbColor: Colors.white,
            overlayColor: const Color(0x336C63FF),
            trackHeight: 6,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value.toDouble(),
            min: AppConstants.kMinDailyStepGoal.toDouble(),
            max: AppConstants.kMaxDailyStepGoal.toDouble(),
            divisions: 49,
            onChanged: (v) => onChanged(v.round()),
          ),
        ).animate(delay: 250.ms).fadeIn(),
       
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [5000, 7500, 10000, 15000].map((goal) {
            final selected = value == goal;
            return GestureDetector(
              onTap: () => onChanged(goal),
              child: AnimatedContainer(
                duration: AppTheme.kFastAnimation,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient:
                      selected ? AppTheme.primaryGradient : null,
                  color: selected ? null : AppTheme.glassWhite,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : AppTheme.glassBorder,
                  ),
                ),
                child: Text(
                  goal >= 1000
                      ? '${(goal / 1000).toStringAsFixed(goal % 1000 == 0 ? 0 : 1)}k'
                      : '$goal',
                  style: TextStyle(
                    color: selected ? Colors.white : AppTheme.onSurfaceMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ).animate(delay: 300.ms).fadeIn(),
      ],
    );
  }
}
