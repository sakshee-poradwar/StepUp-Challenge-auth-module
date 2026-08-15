import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stepauth/core/theme/app_theme.dart';
import 'package:stepauth/presentation/providers/auth_provider.dart';
import 'package:stepauth/presentation/screens/profile/profile_screen.dart';
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final userId = ref.watch(currentUserIdProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
             
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: _buildHeader(context, ref, profileAsync),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: _buildStepRingCard(context, profileAsync),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _buildQuickStats(context),
                ),
              ),
             
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: _buildLeaderboardPlaceholder(context),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  child: _buildCloudSyncPlaceholder(context, userId),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, ref),
    );
  }
  
  Widget _buildHeader(BuildContext context, WidgetRef ref, profileAsync) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              profileAsync.when(
                data: (p) => Text(
                  p?.displayName ?? 'Champion',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                loading: () => const SizedBox(
                  height: 28,
                  width: 120,
                  child: LinearProgressIndicator(),
                ),
                error: (_, __) => const Text('—'),
              ),
            ],
          ),
        ),
       
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: profileAsync.when(
            data: (p) => _AvatarCircle(avatarUrl: p?.avatarUrl),
            loading: () => const _AvatarCircle(),
            error: (_, __) => const _AvatarCircle(),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
  
  Widget _buildStepRingCard(BuildContext context, profileAsync) {
    const int todaySteps = 7247; // INTEGRATION — Member 2: replace with real data
    final goal = profileAsync.valueOrNull?.dailyStepGoal ?? 10000;
    final progress = (todaySteps / goal).clamp(0.0, 1.0);
    return Container(
      decoration: glassDecoration(),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: AppTheme.divider,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShaderMask(
                    shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
                    child: const Text(
                      '7,247',
                      // INTEGRATION — Member 2: replace with actual steps
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -1.5,
                      ),
                    ),
                  ),
                  const Text(
                    'steps today',
                    style: TextStyle(
                      color: AppTheme.onSurfaceMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ).animate().scale(
                begin: const Offset(0.7, 0.7),
                duration: 700.ms,
                curve: Curves.elasticOut,
              ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatChip(label: 'Goal', value: '$goal'),
              _StatChip(label: 'Remaining', value: '${goal - todaySteps}'),
              _StatChip(label: 'Progress', value: '${(progress * 100).round()}%'),
            ],
          ),
        ],
      ),
    ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.15, end: 0);
  }
  
  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: Icons.local_fire_department,
            value: '312',
            label: 'kcal',
            color: const Color(0xFFFF6B35),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.straighten,
            value: '5.2',
            label: 'km',
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.timer_outlined,
            value: '48',
            label: 'min',
            color: AppTheme.primary,
          ),
        ),
      ],
    ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.15, end: 0);
  }
  
  Widget _buildLeaderboardPlaceholder(BuildContext context) {
    return Container(
      decoration: glassDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.leaderboard, color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text('Leaderboard', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            '🏆 Global leaderboard coming soon!\n'
            'Member 3 (Social) will plug in LeaderboardWidget here.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.onSurfaceMuted),
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.15, end: 0);
  }
  
  Widget _buildCloudSyncPlaceholder(BuildContext context, String? userId) {
    return Container(
      decoration: glassDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cloud_sync, color: AppTheme.accent, size: 20),
              const SizedBox(width: 8),
              Text('Cloud Sync', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sync, size: 16),
                label: const Text('Sync Now'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accent,
                  side: const BorderSide(color: AppTheme.accent),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            userId != null ? 'User ID: $userId' : 'Not signed in',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.onSurfaceMuted, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '☁️ Member 2 (Cloud Sync) will call syncStepsToCloud(userId)\n'
            'and store steps in users/{uid}/dailySteps/{date}.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.onSurfaceMuted),
          ),
        ],
      ),
    ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.15, end: 0);
  }
  
  Widget _buildBottomNav(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        border: const Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.onSurfaceMuted,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          
          BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined), label: 'Leaderboard'),
          
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline), label: 'Friends'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
        onTap: (i) {
          if (i == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
      ),
    );
  }
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({this.avatarUrl});
  final String? avatarUrl;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.primaryGradient,
      ),
      child: ClipOval(
        child: avatarUrl != null
            ? Image.network(avatarUrl!, fit: BoxFit.cover)
            : const Icon(Icons.person, color: Colors.white, size: 24),
      ),
    );
  }
}
class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.onSurfaceMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: glassDecoration(),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.onSurfaceMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
