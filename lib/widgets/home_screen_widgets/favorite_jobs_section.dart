import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/l10n/app_localizations.dart';
import 'package:job_seeker/models/jobs_screen_models/job_model.dart';
import 'package:job_seeker/providers/home_screen_providers/favorites_provider.dart';
import 'package:job_seeker/widgets/common/shimmer_loading.dart';
import 'package:job_seeker/widgets/jobs_screen_widgets/job_card.dart';

/// Section widget for displaying favorite jobs on the home screen.
/// Handles loading, empty, error, and success states with graceful fallbacks.
class FavoriteJobsSection extends ConsumerWidget {
  const FavoriteJobsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final favoritesValue = ref.watch(favoriteJobsProvider);

    return favoritesValue.when(
      data: (state) {
        if (state.jobs.isEmpty) {
          return _EmptyFavoritesState();
        }
        return _FavoriteJobsList(
          jobs: state.jobs,
          hasPartialErrors: state.isPartiallyLoaded,
          failedCount: state.failedIds.length,
          onRetry: () {
            HapticFeedback.selectionClick();
            ref.read(favoriteJobsProvider.notifier).retryFailedJobs();
          },
        );
      },
      loading: () => const _FavoritesSkeletonLoader(),
      error: (e, st) => _FavoritesErrorState(
        message: l10n.failedToLoadSaved,
        onRetry: () {
          HapticFeedback.selectionClick();
          ref.invalidate(favoriteJobsProvider);
        },
      ),
    );
  }
}

class _FavoriteJobsList extends StatelessWidget {
  final List<JobModel> jobs;
  final bool hasPartialErrors;
  final int failedCount;
  final VoidCallback onRetry;

  const _FavoriteJobsList({
    required this.jobs,
    required this.hasPartialErrors,
    required this.failedCount,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Partial error banner
        if (hasPartialErrors)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _PartialErrorBanner(
              failedCount: failedCount,
              onRetry: onRetry,
            ),
          ),

        const SizedBox(height: 8),

        // Unbounded vertical list of job cards
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: JobCard(job: jobs[index], isViewed: false, onTap: () {}),
            );
          },
        ),
      ],
    );
  }
}

class _PartialErrorBanner extends StatelessWidget {
  final int failedCount;
  final VoidCallback onRetry;

  const _PartialErrorBanner({required this.failedCount, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: theme.colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Text(
            l10n.failedToLoadSaved,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              l10n.retry,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavoritesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 24,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.noSavedJobsYet,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap the heart icon on any job to save it here',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesSkeletonLoader extends StatelessWidget {
  const _FavoritesSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: ShimmerLoading(width: double.infinity, height: 180, borderRadius: 16),
        );
      },
    );
  }
}

class _FavoritesErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _FavoritesErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 32,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Try Again',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onError,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
