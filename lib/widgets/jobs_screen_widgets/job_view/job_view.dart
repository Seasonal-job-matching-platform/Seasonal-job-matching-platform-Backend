import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_seeker/l10n/app_localizations.dart';
import 'package:job_seeker/models/jobs_screen_models/job_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/providers/jobs_screen_providers/job_apply_provider.dart';
import 'package:job_seeker/providers/home_screen_providers/favorites_controller.dart';
import 'package:job_seeker/providers/profile_screen_providers/personal_information_notifier.dart';
import 'package:job_seeker/widgets/jobs_screen_widgets/job_view/job_apply_dialog.dart';
import 'package:job_seeker/widgets/jobs_screen_widgets/job_view/job_comments_section.dart';

import 'package:job_seeker/utils/job_color_util.dart';

class JobView extends ConsumerWidget {
  final JobModel job;

  const JobView({super.key, required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isOpen = job.status.toLowerCase() == "open";
    final personal = ref.watch(personalInformationProvider);
    final isFav = personal.maybeWhen(
      data: (u) => u.favoriteJobs.contains(job.id),
      orElse: () => false,
    );
    final theme = Theme.of(context);
    final companyColor = JobColorUtil.getJobColor(job.id, job.title);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Minimal Pinned AppBar (No big header)
              SliverAppBar(
                expandedHeight: 0, // Removed big header
                toolbarHeight: 64,
                pinned: true,
                backgroundColor: companyColor,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                centerTitle: true,
                title: Text(
                  job.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.bookmark_border_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(favoritesControllerProvider.notifier)
                          .toggle(job.id.toString());
                    },
                  ),
                ],
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Title & Logo Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade100),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                job.jobposterName.isNotEmpty
                                    ? job.jobposterName[0].toUpperCase()
                                    : 'C',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: companyColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.title,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF1E293B),
                                        height: 1.2,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                _StatusPill(isOpen: isOpen),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Tags Vertical Stack (Requested)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _JobTag(
                            text: job.location,
                            icon: Icons.location_on_outlined,
                            color: Colors.blue.shade50,
                            textColor: Colors.blue.shade700,
                          ),
                          const SizedBox(height: 8),
                          _JobTag(
                            text: job.type,
                            icon: Icons.access_time_rounded,
                            color: Colors.purple.shade50,
                            textColor: Colors.purple.shade700,
                          ),
                          if (job.categories.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: job.categories
                                  .map(
                                    (c) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Text(
                                        c,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Salary (Compact)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.attach_money_rounded,
                                color: Colors.green.shade700,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Salary Rate',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '\$${job.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              job.salary
                                  .toLowerCase()
                                  .replaceAll("salary", "")
                                  .trim(),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Description
                      _SectionTitle(title: l10n.description),
                      const SizedBox(height: 12),
                      Text(
                        job.description,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Requirements
                      if (job.requirements.isNotEmpty) ...[
                        _SectionTitle(title: l10n.requirements),
                        const SizedBox(height: 16),
                        ...job.requirements.map(
                          (req) => _BulletPoint(text: req),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Benefits
                      if (job.benefits.isNotEmpty) ...[
                        _SectionTitle(title: l10n.benefits),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          children: job.benefits
                              .map((benefit) => _BenefitChip(text: benefit))
                              .toList(),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Q&A Comments Section
                      JobCommentsSection(
                        jobId: job.id,
                        jobPosterId: job.jobposterId,
                      ),

                      // Bottom Padding
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Glassmorphic Sticky Apply Bar (Smaller & Glass)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ), // Glass Effect
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    12 + MediaQuery.of(context).padding.bottom,
                  ), // Reduced padding
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.7,
                    ), // Transparent white
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ApplyButton(
                          job: job,
                          isOpen: isOpen,
                          color: companyColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isOpen;
  const _StatusPill({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isOpen
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        isOpen ? l10n.openPosition : l10n.closed,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isOpen ? Colors.green.shade700 : Colors.red.shade700,
        ),
      ),
    );
  }
}

class _JobTag extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final IconData icon;

  const _JobTag({
    required this.text,
    required this.color,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: textColor.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF334155)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitChip extends StatelessWidget {
  final String text;
  const _BenefitChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplyButton extends ConsumerWidget {
  final JobModel job;
  final bool isOpen;
  final Color color;

  const _ApplyButton({
    required this.job,
    required this.isOpen,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final hasApplied = ref.watch(jobAppliedProvider(job.id.toString()));
    final applyState = ref.watch(applyControllerProvider);
    final isLoading = applyState.isLoading;
    final isEnabled = isOpen && !isLoading && !hasApplied;

    return SizedBox(
      height: 48, // Reduced height
      child: ElevatedButton(
        onPressed: isEnabled
            ? () async {
                await showJobApplyDialog(context, ref, job.id);
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? color : Colors.grey.shade300,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Smaller radius
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                hasApplied ? l10n.applied : l10n.applyNow,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
