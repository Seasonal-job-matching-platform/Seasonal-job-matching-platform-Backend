import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/l10n/app_localizations.dart';
import 'package:job_seeker/providers/profile_screen_providers/personal_information_notifier.dart';
import 'package:job_seeker/models/profile_screen_models/personal_information_model.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/countries.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _countryController;
  String _completePhoneNumber = '';
  String _initialCountryCode = 'EG';
  String _initialNumber = '';

  List<String> _initialInterests = [];
  List<String> _currentInterests = [];
  List<String> selectedInterests = [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _countryController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _initializeData(PersonalInformationModel user) {
    if (_initialized) return;
    _nameController.text = user.name;
    _countryController.text = user.country;

    String phoneNumber = user.number;
    String normalizedPhone = phoneNumber.replaceAll(RegExp(r'[+\-\s]'), '');
    String countryCode = 'EG';
    String number = normalizedPhone;

    try {
      final sortedCountries = List.from(countries)
        ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));

      for (var country in sortedCountries) {
        if (normalizedPhone.startsWith(country.dialCode)) {
          countryCode = country.code;
          number = normalizedPhone.substring(country.dialCode.length);
          break;
        }
      }
    } catch (e) {
      // Fallback
    }

    _completePhoneNumber = user.number;
    _initialCountryCode = countryCode;
    _initialNumber = number;

    _initialInterests = List.from(user.fieldsOfInterest ?? []);
    _currentInterests = List.from(_initialInterests);
    _initialized = true;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(personalInformationProvider.notifier);
    final user = ref.read(personalInformationProvider).value!;

    try {
      // Update basic info one by one if changed
      if (_nameController.text != user.name) {
        await notifier.updateName(_nameController.text);
      }
      if (_completePhoneNumber != user.number) {
        await notifier.updatePhone(_completePhoneNumber);
      }
      if (_countryController.text != user.country) {
        await notifier.updateCountry(_countryController.text);
      }

      // Update interests
      final added = _currentInterests
          .where((i) => !_initialInterests.contains(i))
          .toList();
      final removed = _initialInterests
          .where((i) => !_currentInterests.contains(i))
          .toList();

      if (added.isNotEmpty || removed.isNotEmpty) {
        await notifier.updateFieldsOfInterest(added: added, removed: removed);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    }
  }

  void _addInterest() {
    // Show dialog to add interest
    showDialog(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(context)!;
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(l10n.addInterest),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'e.g. Graphic Design'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    selectedInterests.add(controller.text.trim());
                  });
                  Navigator.pop(dialogContext);
                }
              },
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final personalInfo = ref.watch(personalInformationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.editProfile),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: personalInfo.when(
          data: (user) {
            _initializeData(user);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar Placeholder
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade200,
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildLabel(l10n.fullName2),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(l10n.enterYourFullName),
                      validator: (v) => v!.isEmpty ? l10n.nameIsRequired : null,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel(l10n.phoneNumber),
                    IntlPhoneField(
                      decoration: _inputDecoration(l10n.enterYourNumber),
                      initialValue: _initialNumber,
                      initialCountryCode: _initialCountryCode,
                      onChanged: (phone) {
                        _completePhoneNumber = phone.completeNumber;
                      },
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Country / Location'),
                    TextFormField(
                      controller: _countryController,
                      decoration: _inputDecoration('e.g. New York, USA'),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel(l10n.interests),
                        IconButton(
                          onPressed: _addInterest,
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _currentInterests
                          .map(
                            (interest) => Chip(
                              label: Text(interest),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setState(() {
                                  _currentInterests.remove(interest);
                                });
                              },
                              backgroundColor: Colors.grey.shade50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: Text(
                          l10n.save,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
