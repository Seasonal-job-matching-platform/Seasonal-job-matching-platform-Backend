import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/l10n/app_localizations.dart';
import 'package:job_seeker/providers/jobs_screen_providers/jobs_filter_provider.dart';
import 'package:job_seeker/theme/app_theme.dart';
import 'package:job_seeker/widgets/common/animated_scale_button.dart';
import 'package:job_seeker/models/job_type.dart';

class JobsSearchHeader extends ConsumerStatefulWidget {
  final int? jobCount;

  const JobsSearchHeader({super.key, this.jobCount});

  @override
  ConsumerState<JobsSearchHeader> createState() => _JobsSearchHeaderState();
}

class _JobsSearchHeaderState extends ConsumerState<JobsSearchHeader> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showFilterModal(BuildContext context) {
    _focusNode.unfocus(); // Remove search focus when opening filters
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FilterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final filterState = ref.watch(jobsFilterProvider);
    final hasActiveFilters =
        filterState.searchQuery.isNotEmpty ||
        filterState.selectedType != null ||
        filterState.selectedLocation != null ||
        filterState.salaryType != null;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20, // AppTheme.spaceMd + 4
              16,
              20,
              12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Row
                Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: AnimatedContainer(
                        duration: AppTheme.animFast,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isFocused
                                ? colorScheme.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          onChanged: (value) {
                            ref
                                .read(jobsFilterProvider.notifier)
                                .setSearchQuery(value);
                          },
                          style: theme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'Search jobs...',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 15,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: _isFocused
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref
                                          .read(jobsFilterProvider.notifier)
                                          .setSearchQuery('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter Button
                    AnimatedScaleButton(
                      onPressed: () => _showFilterModal(context),
                      child: Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color:
                              (filterState.selectedLocation != null ||
                                  filterState.salaryType != null)
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest.withValues(
                                  alpha: 0.4,
                                ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color:
                              (filterState.selectedLocation != null ||
                                  filterState.salaryType != null)
                              ? Colors.white
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Quick Filters (Type)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      ...JobType.values.map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: type.localizedLabel(context),
                            isSelected: filterState.selectedType == type.apiValue,
                            onTap: () {
                              _focusNode.unfocus(); // Remove search focus when chip is tapped
                              ref
                                .read(jobsFilterProvider.notifier)
                                .setType(type.apiValue);
                            },
                          ),
                        );
                      }),
                      if (hasActiveFilters) ...[
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            _focusNode.unfocus(); // Unfocus on clear
                            _searchController.clear();
                            ref
                                .read(jobsFilterProvider.notifier)
                                .clearFilters();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.close,
                                  size: 14,
                                  color: colorScheme.error,
                                ),
                                const SizedBox(width: 4),
                                 Text(
                                   l10n.clear,
                                   style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results count bar
          if (widget.jobCount != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.2,
                ),
              ),
               child: Text(
                 '${widget.jobCount} ${widget.jobCount == 1 ? l10n.jobFound : l10n.jobsFound}',
                 style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedScaleButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _FilterModal extends ConsumerStatefulWidget {
  const _FilterModal();

  @override
  ConsumerState<_FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends ConsumerState<_FilterModal> {
  final _locationController = TextEditingController();
  String? _salaryType;

  @override
  void initState() {
    super.initState();
    final state = ref.read(jobsFilterProvider);
    _locationController.text = state.selectedLocation ?? '';
    _salaryType = state.salaryType;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      // Use Padding to push content up above the keyboard
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        // Allow scrolling if content is taller than available space
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
               Text(
                 l10n.filters,
                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
               ),
              const SizedBox(height: 24),

              // Location Input
              Text(
                 l10n.location,
                 style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
               ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'e.g. Remote, New York',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Salary Type Selector
              Text(
                l10n.salaryTypeLabel,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['HOURLY', 'MONTHLY', 'YEARLY'].map((type) {
                  final isSelected = _salaryType == type;
                  // Map API values to localized labels
                  final salaryLabels = {
                    'HOURLY': l10n.hourlySalary,
                    'MONTHLY': l10n.monthlySalary,
                    'YEARLY': l10n.yearlySalary,
                  };
                  return ChoiceChip(
                    label: Text(salaryLabels[type] ?? type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _salaryType = selected ? type : null;
                      });
                    },
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(jobsFilterProvider.notifier).clearFilters();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(l10n.reset),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final notifier = ref.read(jobsFilterProvider.notifier);
                        notifier.setLocation(_locationController.text);
                        notifier.setSalaryType(_salaryType);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l10n.applyFilters),
                    ),
                  ),
                ],
              ),
              // Extra safe area at the bottom
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }
}
