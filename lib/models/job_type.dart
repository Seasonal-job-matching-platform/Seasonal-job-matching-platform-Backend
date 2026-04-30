import 'package:flutter/material.dart';
import 'package:job_seeker/l10n/app_localizations.dart';

enum JobType {
  fullTime,
  partTime,
  freelance,
  contract,
  temporary,
  volunteer,
  internship,
}

extension JobTypeExtension on JobType {
  String get label {
    switch (this) {
      case JobType.fullTime:
        return 'Full Time';
      case JobType.partTime:
        return 'Part Time';
      case JobType.freelance:
        return 'Freelance';
      case JobType.contract:
        return 'Contract';
      case JobType.temporary:
        return 'Temporary';
      case JobType.volunteer:
        return 'Volunteer';
      case JobType.internship:
        return 'Internship';
    }
  }

  /// Returns the localized label for the job type
  String localizedLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case JobType.fullTime:
        return l10n.fullTime;
      case JobType.partTime:
        return l10n.partTime;
      case JobType.freelance:
        return l10n.freelance;
      case JobType.contract:
        return l10n.contract;
      case JobType.temporary:
        return l10n.temporary;
      case JobType.volunteer:
        return l10n.volunteer;
      case JobType.internship:
        return l10n.internship;
    }
  }

  String get apiValue {
    switch (this) {
      case JobType.fullTime:
        return 'FULL_TIME';
      case JobType.partTime:
        return 'PART_TIME';
      case JobType.freelance:
        return 'FREELANCE';
      case JobType.contract:
        return 'CONTRACT';
      case JobType.temporary:
        return 'TEMPORARY';
      case JobType.volunteer:
        return 'VOLUNTEER';
      case JobType.internship:
        return 'INTERNSHIP';
    }
  }
}
