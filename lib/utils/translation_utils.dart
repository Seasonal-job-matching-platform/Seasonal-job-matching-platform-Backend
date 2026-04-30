import 'package:job_seeker/l10n/app_localizations.dart';

class TranslationUtils {
  /// Translates application status strings like 'PENDING', 'ACCEPTED', etc.
  static String translateStatus(String? apiStatus, AppLocalizations l10n) {
    if (apiStatus == null || apiStatus.isEmpty) return l10n.notSet;

    final status = apiStatus.toLowerCase();
    
    if (status.contains('pending')) return l10n.statusPending;
    if (status.contains('accepted') || status.contains('approved')) return l10n.statusAccepted;
    if (status.contains('rejected') || status.contains('declined')) return l10n.statusRejected;
    if (status.contains('interview')) return l10n.statusInterview;
    if (status.contains('submitted')) return l10n.statusSubmitted;
    if (status.contains('closed')) return l10n.statusClosed;
    if (status.contains('open')) return l10n.statusOpen;

    // Fallback if not mapped
    return apiStatus;
  }

  /// Translates job type strings like 'FULL_TIME', 'PART_TIME', etc.
  static String translateJobType(String? apiJobType, AppLocalizations l10n) {
    if (apiJobType == null || apiJobType.isEmpty) return l10n.notSet;

    final type = apiJobType.toLowerCase().replaceAll('_', '');

    if (type.contains('fulltime')) return l10n.fullTime;
    if (type.contains('parttime')) return l10n.partTime;
    if (type.contains('freelance')) return l10n.freelance;
    if (type.contains('contract')) return l10n.contract;
    if (type.contains('temporary') || type.contains('temp')) return l10n.temporary;
    if (type.contains('volunteer')) return l10n.volunteer;
    if (type.contains('internship') || type.contains('intern')) return l10n.internship;

    // Fallback if not mapped
    return apiJobType;
  }

  /// Translates salary type strings like 'HOURLY', 'MONTHLY', etc.
  static String translateSalaryType(String? apiSalaryType, AppLocalizations l10n) {
    if (apiSalaryType == null || apiSalaryType.isEmpty) return l10n.notSet;

    final type = apiSalaryType.toLowerCase();

    if (type.contains('hour')) return l10n.hourly;
    if (type.contains('month')) return l10n.monthly;
    if (type.contains('year')) return l10n.yearly;

    // Fallback if not mapped
    return apiSalaryType;
  }
}
