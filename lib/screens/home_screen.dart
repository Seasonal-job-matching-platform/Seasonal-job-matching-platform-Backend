import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/l10n/app_localizations.dart';
import 'package:job_seeker/providers/home_screen_providers/favorites_provider.dart';
import 'package:job_seeker/providers/home_screen_providers/recommended_jobs_provider.dart';
import 'package:job_seeker/widgets/common/shimmer_loading.dart';
import 'package:job_seeker/widgets/home_screen_widgets/favorite_jobs_section.dart';
import 'package:job_seeker/widgets/home_screen_widgets/recommended_jobs_carousel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recommendedValue = ref.watch(recommendedJobsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        // Refresh both recommended and favorite jobs
        ref.invalidate(recommendedJobsProvider);
        ref.invalidate(favoriteJobsProvider);
        await Future.wait([
          ref.read(recommendedJobsProvider.future),
          ref.read(favoriteJobsProvider.future),
        ]);
      },
      color: const Color(0xFF1C1C1E),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 1. Recommended Section Header
            SliverToBoxAdapter(
              child: _SectionHeader(title: l10n.recommendedForYou),
            ),

            // 2. Recommended Carousel
            recommendedValue.when(
              data: (response) {
                if (response.count == 0) {
                  return SliverToBoxAdapter(child: _EmptyState());
                }
                return SliverToBoxAdapter(
                  child: RecommendedJobsCarousel(jobs: response.jobs),
                );
              },
              loading: () =>
                  SliverToBoxAdapter(child: _RecommendedJobsSkeletonLoader()),
              error: (e, st) => SliverToBoxAdapter(
                child: _ErrorState(
                  message: l10n.failedToLoad,
                  onRetry: () {
                    HapticFeedback.selectionClick();
                    ref.invalidate(recommendedJobsProvider);
                  },
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 32)),

            // 3. Saved Jobs Header
            SliverToBoxAdapter(
              child: _SectionHeader(title: l10n.savedJobs),
            ),

            // 4. Saved Jobs Section
            const SliverToBoxAdapter(child: FavoriteJobsSection()),

            const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C1C1E),
              letterSpacing: -0.5,
            ),
          ),
          // Removed "See All" since it had no function and looked lonely without functionality
        ],
      ),
    );
  }
}

class _RecommendedJobsSkeletonLoader extends StatelessWidget {
  const _RecommendedJobsSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ShimmerLoading(
        width: double.infinity,
        height: 260,
        borderRadius: 24,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 32,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No Recommendations Yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Complete your profile or update your interests to get better matches.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // We could add a button here if we had direct navigation access
          // For now, just the message is better than "No jobs found"
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(message),
          TextButton(onPressed: onRetry, child: const Text("Retry")),
        ],
      ),
    );
  }
}
