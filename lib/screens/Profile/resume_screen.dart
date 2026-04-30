import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/l10n/app_localizations.dart';
import 'package:job_seeker/providers/profile_screen_providers/resume_provider.dart';
import 'package:job_seeker/models/profile_screen_models/resume_model.dart';
import 'package:job_seeker/constants/constants.dart';

class ResumeScreen extends ConsumerStatefulWidget {
  const ResumeScreen({super.key});

  @override
  ConsumerState<ResumeScreen> createState() => _ResumeScreenState();
}

class _ResumeScreenState extends ConsumerState<ResumeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _educationController;
  late TextEditingController _experienceController;
  late TextEditingController _certificatesController;
  late TextEditingController _skillsController;

  List<String> _selectedLanguages = [];

  bool _dataLoaded = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _educationController = TextEditingController();
    _experienceController = TextEditingController();
    _certificatesController = TextEditingController();
    _skillsController = TextEditingController();
  }

  @override
  void dispose() {
    _educationController.dispose();
    _experienceController.dispose();
    _certificatesController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _populateFields(ResumeModel resume) {
    _educationController.text = resume.education.join('\n');
    _experienceController.text = resume.experience.join('\n');
    _certificatesController.text = resume.certificates.join('\n');
    _skillsController.text = resume.skills.join('\n');
    _selectedLanguages = List.from(resume.languages);
  }

  Future<void> _saveResume() async {
    if (_formKey.currentState!.validate()) {
      final education = _educationController.text
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
      final experience = _experienceController.text
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
      final certificates = _certificatesController.text
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
      final skills = _skillsController.text
          .split('\n')
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim())
          .toList();
      final languages = _selectedLanguages;

      final currentResume = ref.read(resumeProvider).value;
      if (currentResume == null) return;

      // Calculate diffs (Keep existing logic or simplify - simplified here for brevity but assuming full update is intended by Provider logic)

      // NOTE: reusing specific logic from previous implementation to be safe with provider expectations
      final educationToRemove = currentResume.education
          .where((e) => !education.contains(e))
          .toList();
      final educationToAdd = education
          .where((e) => !currentResume.education.contains(e))
          .toList();

      final experienceToRemove = currentResume.experience
          .where((e) => !experience.contains(e))
          .toList();
      final experienceToAdd = experience
          .where((e) => !currentResume.experience.contains(e))
          .toList();

      final certificatesToRemove = currentResume.certificates
          .where((e) => !certificates.contains(e))
          .toList();
      final certificatesToAdd = certificates
          .where((e) => !currentResume.certificates.contains(e))
          .toList();

      final skillsToRemove = currentResume.skills
          .where((e) => !skills.contains(e))
          .toList();
      final skillsToAdd = skills
          .where((e) => !currentResume.skills.contains(e))
          .toList();

      final languagesToRemove = currentResume.languages
          .where((e) => !languages.contains(e))
          .toList();
      final languagesToAdd = languages
          .where((e) => !currentResume.languages.contains(e))
          .toList();

      try {
        await ref
            .read(resumeProvider.notifier)
            .updateResume(
              educationToAdd: educationToAdd,
              educationToRemove: educationToRemove,
              experienceToAdd: experienceToAdd,
              experienceToRemove: experienceToRemove,
              certificatesToAdd: certificatesToAdd,
              certificatesToRemove: certificatesToRemove,
              skillsToAdd: skillsToAdd,
              skillsToRemove: skillsToRemove,
              languagesToAdd: languagesToAdd,
              languagesToRemove: languagesToRemove,
            );

        if (mounted) {
          setState(() {
            _isEditing = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Resume updated!')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resumeState = ref.watch(resumeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          l10n.myJobResume,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          resumeState.hasValue && resumeState.value != null
              ? IconButton(
                  icon: Icon(
                    _isEditing ? Icons.check_circle : Icons.edit_note_rounded,
                  ),
                  color: _isEditing ? Colors.green : Colors.black87,
                  iconSize: 28,
                  onPressed: () {
                    if (_isEditing) {
                      _saveResume();
                    } else {
                      // Populate before editing to be sure
                      _populateFields(resumeState.value!);
                      setState(() => _isEditing = true);
                    }
                  },
                  tooltip: _isEditing ? l10n.save : l10n.editProfile,
                )
              : const SizedBox(),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: resumeState.when(
          data: (resume) {
            if (resume == null) {
              return _buildEmptyState();
            }

            if (!_dataLoaded && !_isEditing) {
              // Pre-populate just in case
              _populateFields(resume);
              _dataLoaded = true;
            }

            if (_isEditing) {
              return _buildEditForm();
            } else {
              return _buildResumeView(resume);
            }
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.description_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No resume created yet.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.read(resumeProvider.notifier).createResume(),
            icon: const Icon(Icons.add),
            label: Text(l10n.createResume),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeView(ResumeModel resume) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildInfoCard(
            title: l10n.experience,
            icon: Icons.work_outline,
            items: resume.experience,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: l10n.education,
            icon: Icons.school_outlined,
            items: resume.education,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: l10n.skills,
            icon: Icons.psychology_outlined,
            items: resume.skills,
            color: Colors.purple,
            isTags: true,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: l10n.languages,
            icon: Icons.language,
            items: resume.languages,
            color: Colors.green,
            isTags: true,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            title: l10n.certificates,
            icon: Icons.card_membership,
            items: resume.certificates,
            color: Colors.teal,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<String> items,
    required Color color,
    bool isTags = false,
  }) {
    if (items.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isTags)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.circle,
                        size: 6,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
              _educationController,
              l10n.education,
              'Add education details...',
              Icons.school_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _experienceController,
              l10n.experience,
              'Add work experience...',
              Icons.work_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _skillsController,
              l10n.skills,
              'Add skills (one per line)...',
              Icons.psychology_outlined,
            ),
            const SizedBox(height: 16),
            _buildLanguageSelector(),
            const SizedBox(height: 16),
            _buildTextField(
              _certificatesController,
              l10n.certificates,
              'Add certificates...',
              Icons.card_membership,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.language, color: Colors.grey.shade400),
              const SizedBox(width: 12),
              Text(
                l10n.languages,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          if (_selectedLanguages.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedLanguages
                  .map(
                    (lang) => Chip(
                      label: Text(lang),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedLanguages.remove(lang);
                        });
                      },
                      backgroundColor: Colors.blue.shade50,
                      labelStyle: TextStyle(color: Colors.blue.shade700),
                      deleteIconColor: Colors.blue.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Colors.blue.shade100),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            key: ValueKey('language_dropdown_${_selectedLanguages.length}'),
            decoration: InputDecoration(
              hintText: 'Add a language...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
            ),
            isExpanded: true,
            icon: const Icon(Icons.add_circle_outline),
            items: languagesList.map((String lang) {
              final isSelected = _selectedLanguages.contains(lang);
              return DropdownMenuItem<String>(
                value: lang,
                enabled: !isSelected,
                child: Text(
                  lang,
                  style: TextStyle(
                    color: isSelected ? Colors.grey : Colors.black87,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                if (_selectedLanguages.contains(newValue)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$newValue is already added.')),
                  );
                  return;
                }
                setState(() {
                  _selectedLanguages.add(newValue);
                });
                // The Key change will force a reset of the widget state
              }
            },
            initialValue: null,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        minLines: 1,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
