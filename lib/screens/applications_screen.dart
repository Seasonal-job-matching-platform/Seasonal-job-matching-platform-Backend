import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/providers/applications_screen_providers/applications_provider.dart';
import 'package:job_seeker/services/applications_screen_services/applications_service.dart';
import 'package:job_seeker/theme/app_theme.dart';
import 'package:job_seeker/widgets/common/async_value_view.dart';
import 'package:job_seeker/screens/applications_detail_screen.dart';
import 'package:job_seeker/widgets/common/app_card.dart';
import 'package:job_seeker/widgets/common/shimmer_loading.dart';
import 'package:job_seeker/widgets/common/staggered_list_item.dart';
import 'package:job_seeker/widgets/common/status_badge.dart';
import 'package:job_seeker/utils/translation_utils.dart';
import 'package:job_seeker/widgets/common/animated_scale_button.dart';
import 'package:job_seeker/l10n/app_localizations.dart';

class ApplicationsScreen extends ConsumerWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsValue = ref.watch(applicationsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Applications List
        Expanded(
          child: SafeArea(
            top: false,
            child: AsyncValueView<List<ApplicationWithJob>>(
              value: applicationsValue,
              data: (apps) {
                if (apps.isEmpty) {
                  return _EmptyApplicationsState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(applicationsProvider);
                  },
                  color: colorScheme.primary,
                  backgroundColor: colorScheme.surface,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.spaceMd,
                      AppTheme.spaceMd,
                      AppTheme.spaceMd,
                      120,
                    ),
                    itemCount: apps.length,
                    itemBuilder: (context, i) {
                      final isFirst = i == 0;
                      final isLast = i == apps.length - 1;

                      return StaggeredListItem(
                        index: i,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppTheme.spaceSm,
                          ),
                          child: _TimelineApplicationCard(
                            item: apps[i],
                            isFirst: isFirst,
                            isLast: isLast,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => ApplicationDetailScreen(
                                        item: apps[i],
                                      ),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position:
                                                Tween<Offset>(
                                                  begin: const Offset(0.05, 0),
                                                  end: Offset.zero,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: animation,
                                                    curve: AppTheme
                                                        .curveEmphasized,
                                                  ),
                                                ),
                                            child: child,
                                          ),
                                        );
                                      },
                                  transitionDuration: AppTheme.animFast,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: _ApplicationsSkeletonLoader(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Timeline Application Card with left timeline indicator
class _TimelineApplicationCard extends StatelessWidget {
  final ApplicationWithJob item;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const _TimelineApplicationCard({
    required this.item,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
  });

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    final s = status.toLowerCase();
    if (s.contains('pending') || s.contains('submitted')) {
      return Colors.amber;
    } else if (s.contains('approved') || s.contains('accepted')) {
      return Colors.green;
    } else if (s.contains('rejected') || s.contains('declined')) {
      return colorScheme.error;
    } else if (s.contains('interview')) {
      return colorScheme.primary;
    }
    return colorScheme.outline;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final job = item.job;
    final app = item.application;
    final statusColor = _getStatusColor(app.applicationStatus, colorScheme);
    final isJobOpen = job.status.toLowerCase() == 'open';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        _TimelineIndicator(
          color: statusColor,
          isFirst: isFirst,
          isLast: isLast,
        ),
        const SizedBox(width: AppTheme.spaceSm),

        // Card content
        Expanded(
          child: AnimatedScaleButton(
            onPressed: onTap,
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  color: colorScheme.surface,
                  boxShadow: AppTheme.shadowSm(colorScheme.shadow),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Status
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spaceMd),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.08),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppTheme.radiusMd),
                          topRight: Radius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spaceSm),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSm,
                              ),
                            ),
                            child: Icon(
                              _getStatusIcon(app.applicationStatus),
                              color: statusColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.applicationStatus,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  app.applicationStatus,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StatusBadge(
                            status: job.status,
                            type: isJobOpen
                                ? StatusType.success
                                : StatusType.neutral,
                            compact: true,
                          ),
                        ],
                      ),
                    ),

                    // Job Info
                    Padding(
                      padding: const EdgeInsets.all(AppTheme.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppTheme.spaceSm),
                          Wrap(
                            spacing: AppTheme.spaceMd,
                            runSpacing: AppTheme.spaceXs,
                            children: [
                              _InfoRow(
                                icon: Icons.location_on_outlined,
                                text: job.location,
                              ),
                              _InfoRow(
                                icon: Icons.work_outline,
                                text: job.type,
                              ),
                              ...job.categories
                                  .take(2)
                                  .map(
                                    (c) => _InfoRow(
                                      icon: Icons.category_outlined,
                                      text: c,
                                      subtle: true,
                                    ),
                                  ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spaceSm),
                          _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            text:
                                'Applied: ${app.createdAt ?? app.appliedDate ?? "N/A"}',
                            subtle: true,
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceMd,
                        vertical: AppTheme.spaceSm,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(AppTheme.radiusMd),
                          bottomRight: Radius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                                l10n.tapToView,
                                style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(String status) {
    final s = status.toLowerCase();
    if (s.contains('pending') || s.contains('submitted')) {
      return Icons.schedule;
    } else if (s.contains('approved') || s.contains('accepted')) {
      return Icons.check_circle;
    } else if (s.contains('rejected') || s.contains('declined')) {
      return Icons.cancel;
    } else if (s.contains('interview')) {
      return Icons.event;
    }
    return Icons.info;
  }
}

/// Timeline indicator with connecting line
class _TimelineIndicator extends StatelessWidget {
  final Color color;
  final bool isFirst;
  final bool isLast;

  const _TimelineIndicator({
    required this.color,
    required this.isFirst,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top line
          if (!isFirst)
            Container(
              width: 2,
              height: 16,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          // Dot
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Bottom line - use fixed height instead of Expanded
          if (!isLast)
            Container(
              width: 2,
              height: 120,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
        ],
      ),
    );
  }
}

/// Info row with icon and text
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool subtle;

  const _InfoRow({required this.icon, required this.text, this.subtle = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: subtle
              ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
              : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: subtle
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Skeleton loader for applications
class _ApplicationsSkeletonLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceMd,
        AppTheme.spaceMd,
        AppTheme.spaceMd,
        120,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline skeleton
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    if (index > 0)
                      ShimmerLoading(width: 2, height: 16, borderRadius: 0),
                    ShimmerLoading.circle(size: 16),
                    ShimmerLoading(width: 2, height: 140, borderRadius: 0),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              // Card skeleton
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          ShimmerLoading(
                            width: 40,
                            height: 40,
                            borderRadius: AppTheme.radiusSm,
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerLoading.text(width: 100),
                                const SizedBox(height: 4),
                                ShimmerLoading.text(width: 60, height: 12),
                              ],
                            ),
                          ),
                          ShimmerLoading(
                            width: 60,
                            height: 24,
                            borderRadius: AppTheme.radiusFull,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      // Title
                      ShimmerLoading.text(width: 180),
                      const SizedBox(height: AppTheme.spaceSm),
                      // Info row
                      Row(
                        children: [
                          ShimmerLoading.text(width: 80, height: 12),
                          const SizedBox(width: AppTheme.spaceMd),
                          ShimmerLoading.text(width: 60, height: 12),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spaceSm),
                      ShimmerLoading.text(width: 120, height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Empty state widget
class _EmptyApplicationsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(scale: value, child: child);
              },
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spaceLg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.secondary.withValues(alpha: 0.2),
                      colorScheme.primary.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 56,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              l10n.noApplications,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              'You haven\'t applied to any jobs yet.\nStart exploring opportunities!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            FilledButton.icon(
              onPressed: () {
                // Navigate to jobs
              },
              icon: const Icon(Icons.search),
              label: Text(l10n.exploreJobs),
            ),
          ],
        ),
      ),
    );
  }
}
