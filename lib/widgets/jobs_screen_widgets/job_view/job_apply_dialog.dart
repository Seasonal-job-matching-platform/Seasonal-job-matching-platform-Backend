import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/l10n/app_localizations.dart';
import 'package:job_seeker/providers/jobs_screen_providers/job_apply_provider.dart';

Future<void> showJobApplyDialog(
  BuildContext context,
  WidgetRef ref,
  int jobId,
) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _JobApplySheet(jobId: jobId),
  );
}

class _JobApplySheet extends ConsumerStatefulWidget {
  final int jobId;

  const _JobApplySheet({required this.jobId});

  @override
  ConsumerState<_JobApplySheet> createState() => _JobApplySheetState();
}

class _JobApplySheetState extends ConsumerState<_JobApplySheet> {
  late final TextEditingController _controller;
  late final GlobalKey<FormState> _formKey;
  bool _showSuccess = false;
  late AppLocalizations l10n;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    try {
      await ref
          .read(applyControllerProvider.notifier)
          .apply(
            jobId: widget.jobId.toString(),
            description: _controller.text.trim(),
          );

      if (mounted) {
        setState(() => _showSuccess = true);

        await Future.delayed(const Duration(seconds: 2));

        if (mounted && context.mounted) {
          Navigator.of(context).pop(); // Close sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.applicationSubmittedSuccess),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    l10n = AppLocalizations.of(context)!;
    final applyState = ref.watch(applyControllerProvider);
    final isLoading = applyState.isLoading;
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + keyboardSpace + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
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

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showSuccess
                ? _buildSuccessView()
                : _buildFormView(isLoading),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      key: const ValueKey('success'),
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF10B981),
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.applicationSent,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.goodLuckEmployer,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildFormView(bool isLoading) {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.applyForPosition,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _controller,
            maxLines: 5,
            enabled: !isLoading,
            decoration: InputDecoration(
              hintText: l10n.tellUsWhy,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF4E60FF),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (v) {
              if (v == null || v.trim().length < 20) {
                return l10n.pleaseWriteAtLeast20;
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4E60FF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    l10n.submitApplication,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    );
  }
}
