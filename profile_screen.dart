import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepauth/core/constants/app_constants.dart';
import 'package:stepauth/core/theme/app_theme.dart';
import 'package:stepauth/presentation/providers/auth_provider.dart';
import 'package:stepauth/presentation/providers/profile_provider.dart';
import 'package:stepauth/presentation/widgets/loading_overlay.dart';
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameCtrl;
  bool _isEditing = false;
  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileStreamProvider).valueOrNull;
    _nameCtrl = TextEditingController(text: profile?.displayName ?? '');
  }
  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final editState = ref.watch(profileEditProvider);
   
    ref.listen(profileEditProvider, (prev, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppTheme.success,
          ),
        );
        ref.read(profileEditProvider.notifier).clearMessages();
        setState(() => _isEditing = false);
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppTheme.error,
          ),
        );
        ref.read(profileEditProvider.notifier).clearMessages();
      }
    });
    return LoadingOverlay(
      isLoading: editState.isLoading,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.backgroundGradient,
          ),
          child: profileAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (profile) => CustomScrollView(
              slivers: [
                _buildAppBar(context, profile?.displayName ?? 'Profile'),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildAvatarSection(profile?.avatarUrl),
                        const SizedBox(height: 28),
                        _buildProfileCard(profile),
                        const SizedBox(height: 20),
                        _buildStatsCard(profile),
                        const SizedBox(height: 20),
                        _buildFriendsPlaceholder(),
                        const SizedBox(height: 20),
                        _buildSignOutButton(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBar(BuildContext context, String title) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      title: Text(title),
      actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined),
          color: AppTheme.primary,
          onPressed: () => setState(() => _isEditing = !_isEditing),
        ),
      ],
    );
  }
  
  Widget _buildAvatarSection(String? avatarUrl) {
    return Stack(
      alignment: Alignment.center,
      children: [
        
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.accentGradient,
            boxShadow: const [
              BoxShadow(
                color: Color(0x5500D4AA),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
        
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surface,
          ),
          child: ClipOval(
            child: avatarUrl != null
                ? CachedNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        const Icon(Icons.person, size: 48, color: AppTheme.onSurfaceMuted),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.person, size: 48, color: AppTheme.onSurfaceMuted),
                  )
                : const Icon(Icons.person, size: 48, color: AppTheme.onSurfaceMuted),
          ),
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () =>
                  ref.read(profileEditProvider.notifier).pickAndUploadAvatar(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    ).animate().scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut);
  }
  
  Widget _buildProfileCard(profile) {
    final editState = ref.watch(profileEditProvider);
    final notifier = ref.read(profileEditProvider.notifier);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: glassDecoration(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile Details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              
              if (_isEditing)
                TextFormField(
                  controller: _nameCtrl,
                  onChanged: notifier.updateDisplayName,
                  style: const TextStyle(color: AppTheme.onSurface),
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    prefixIcon: Icon(Icons.person_outline, size: 20),
                  ),
                )
              else
                _ProfileRow(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: profile?.displayName ?? '—',
                ),
              const SizedBox(height: 16),
              _ProfileRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: profile?.email ?? '—',
              ),
              const SizedBox(height: 16),
              _ProfileRow(
                icon: Icons.fingerprint,
                label: 'User ID',
                value: profile?.uid ?? '—',
                subtitle: 'Tap to copy',
                onTap: () {
                  if (profile?.uid != null) {
                    Clipboard.setData(ClipboardData(text: profile!.uid));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User ID copied!')),
                    );
                  }
                },
              ),
              
              if (_isEditing) ...[
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: notifier.saveProfile,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }
 
  Widget _buildStatsCard(profile) {
    final editState = ref.watch(profileEditProvider);
    final notifier = ref.read(profileEditProvider.notifier);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: glassDecoration(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.flag_outlined,
                      color: AppTheme.accent, size: 20),
                  const SizedBox(width: 8),
                  Text('Daily Goal', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ShaderMask(
                  shaderCallback: (b) => AppTheme.accentGradient.createShader(b),
                  child: Text(
                    '${(editState.dailyStepGoal).toString().replaceAllMapped(
                          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                          (m) => '${m[1]},',
                        )} steps',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isEditing) ...[
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.accent,
                    inactiveTrackColor: AppTheme.divider,
                    thumbColor: Colors.white,
                    overlayColor: const Color(0x3300D4AA),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: editState.dailyStepGoal.toDouble(),
                    min: AppConstants.kMinDailyStepGoal.toDouble(),
                    max: AppConstants.kMaxDailyStepGoal.toDouble(),
                    divisions: 49,
                    onChanged: (v) => notifier.updateDailyStepGoal(v.round()),
                  ),
                ),
              ] else ...[
                
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 0.72,
                    backgroundColor: AppTheme.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '7,200 / ${editState.dailyStepGoal.toString()} steps today',
                  
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.onSurfaceMuted),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }
  
  Widget _buildFriendsPlaceholder() {
    return Container(
      decoration: glassDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_outline, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('Friends', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
             
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(color: AppTheme.primary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '👋 Friends and leaderboards coming soon!\n'
            'Member 3 (Social) will plug in here.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.onSurfaceMuted),
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0);
  }
 
  Widget _buildSignOutButton() {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.surfaceVariant,
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await ref.read(authNotifierProvider.notifier).signOut();
        }
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: glassDecoration(),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: AppTheme.error, size: 18),
            SizedBox(width: 8),
            Text(
              'Sign Out',
              style: TextStyle(
                color: AppTheme.error,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 400.ms).fadeIn();
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.glassWhite,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.onSurfaceMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.copy, size: 16, color: AppTheme.onSurfaceMuted),
        ],
      ),
    );
  }
}
