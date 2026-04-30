import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:job_seeker/l10n/app_localizations.dart';
import 'package:job_seeker/models/jobs_screen_models/job_model.dart';
import 'package:job_seeker/theme/app_theme.dart';
import 'package:job_seeker/widgets/jobs_screen_widgets/job_view/job_view.dart';
import 'package:job_seeker/providers/home_screen_providers/favorites_controller.dart';
import 'package:job_seeker/providers/profile_screen_providers/personal_information_notifier.dart';
import 'package:job_seeker/widgets/common/app_card.dart';
import 'package:job_seeker/widgets/common/animated_scale_button.dart';
import 'package:job_seeker/widgets/common/status_badge.dart';

import 'package:job_seeker/widgets/common/new_badge.dart';
import 'package:job_seeker/utils/job_color_util.dart';

class JobCard extends ConsumerStatefulWidget {
  final JobModel job;

  /// Whether this job has been viewed in the current session
  final bool isViewed;

  /// Optional callback when job is tapped (for marking as viewed)
  final VoidCallback? onTap;

  const JobCard({
    super.key,
    required this.job,
    this.isViewed = false,
    this.onTap,
  });

  @override
  ConsumerState<JobCard> createState() => _JobCardState();
}

class _JobCardState extends ConsumerState<JobCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: AppTheme.animFast, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.curveDefault),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date;
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          date = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } else {
          return dateStr;
        }
      }
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  bool _isRecentlyPosted(String dateStr) {
    try {
      DateTime date;
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          date = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } else {
          return false;
        }
      }
      return DateTime.now().difference(date).inDays <= 7;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final formattedStart = _formatDate(widget.job.startDate);
    final isOpen = widget.job.status.toLowerCase() == 'open';
    final isRecent = _isRecentlyPosted(widget.job.startDate);
    final companyColor = JobColorUtil.getJobColor(
      widget.job.id,
      widget.job.title,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: AppTheme.spaceSm,
      ),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          HapticFeedback.selectionClick();
          // Call onTap to mark job as viewed
          widget.onTap?.call();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => JobView(job: widget.job)),
          );
        },
        onTapCancel: () => _controller.reverse(),
        // Apply opacity dimming for viewed jobs
        child: Opacity(
          opacity: widget.isViewed ? 0.65 : 1.0,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd + 2),
                  color: colorScheme.surface,
                  boxShadow: AppTheme.shadowSm(colorScheme.shadow),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with company avatar, title, and favorite
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppTheme.spaceMd,
                        AppTheme.spaceMd,
                        AppTheme.spaceMd,
                        AppTheme.spaceSm,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Company Avatar
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  companyColor,
                                  companyColor.withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSm,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: companyColor.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                widget.job.jobposterName.isNotEmpty
                                    ? widget.job.jobposterName[0].toUpperCase()
                                    : 'C',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.job.title,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: colorScheme.onSurface,
                                              height: 1.3,
                                            ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    // New badge
                                    if (isRecent)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: AppTheme.spaceXs,
                                        ),
                                        child: NewBadge(animate: true, text: l10n.newBadge),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.job.jobposterName.isNotEmpty
                                      ? widget.job.jobposterName
                                      : 'Company Name',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppTheme.spaceSm),
                          _FavoriteButton(jobId: widget.job.id),
                        ],
                      ),
                    ),

                    // Info Chips
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceMd,
                      ),
                      child: Wrap(
                        spacing: AppTheme.spaceSm,
                        runSpacing: AppTheme.spaceSm,
                        children: [
                          _InfoChip(
                            icon: Icons.location_on_outlined,
                            label: widget.job.location,
                          ),
                          _InfoChip(
                            icon: Icons.work_outline,
                            label: widget.job.type,
                          ),
                          ...widget.job.categories
                              .take(2)
                              .map(
                                (c) => _InfoChip(
                                  icon: Icons.category_rounded,
                                  label: c,
                                ),
                              ),
                          if (!isOpen)
                            const StatusBadge(
                              status: 'Closed',
                              type: StatusType.error,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.spaceMd),

                    // Footer with Salary and Date
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceMd,
                        vertical: AppTheme.spaceSm + 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(AppTheme.radiusMd + 2),
                          bottomRight: Radius.circular(AppTheme.radiusMd + 2),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spaceSm,
                                  vertical: AppTheme.spaceXxs,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSm,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.payments_outlined,
                                      size: 16,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '\$${NumberFormat('#,##0').format(widget.job.amount)}',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: colorScheme.primary,
                                          ),
                                    ),
                                    Text(
                                      ' / ${widget.job.salary.toLowerCase().replaceAll('salary', '').trim()}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: colorScheme.primary
                                                .withValues(alpha: 0.7),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 14,
                                color: colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formattedStart,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ), // Close ScaleTransition
        ), // Close Opacity
      ), // Close GestureDetector
    ); // Close Padding
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceXs + 4,
        vertical: AppTheme.spaceXxs + 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends ConsumerStatefulWidget {
  final int jobId;

  const _FavoriteButton({required this.jobId});

  @override
  ConsumerState<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final personalInfo = ref.watch(personalInformationProvider);
    final isFav = personalInfo.maybeWhen(
      data: (u) => u.favoriteJobs.contains(widget.jobId),
      orElse: () => false,
      loading: () => false,
    );

    return AnimatedScaleButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        _scaleController.forward(from: 0);
        ref
            .read(favoritesControllerProvider.notifier)
            .toggle(widget.jobId.toString());
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppTheme.animFast,
          padding: const EdgeInsets.all(AppTheme.spaceSm),
          decoration: BoxDecoration(
            color: isFav
                ? colorScheme.error.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav
                ? colorScheme.error
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            size: 20,
          ),
        ),
      ),
    );
  }
}
