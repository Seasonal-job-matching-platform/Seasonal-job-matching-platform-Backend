import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:job_seeker/models/profile_screen_models/personal_information_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/services/profile_screen_services/personal_information_service.dart';
import 'package:job_seeker/providers/home_screen_providers/favorites_provider.dart';

final personalInformationProvider =
    AsyncNotifierProvider<
      PersonalInformationAsyncNotifier,
      PersonalInformationModel
    >(PersonalInformationAsyncNotifier.new);

class PersonalInformationAsyncNotifier
    extends AsyncNotifier<PersonalInformationModel> {
  late final PersonalInformationService _service = ref.read(
    personalInformationServiceProvider,
  );

  @override
  Future<PersonalInformationModel> build() async {
    // Fetch user data
    final userData = await _service.fetchUserData();

    // Fetch applied job IDs from the dedicated API endpoint
    final appliedJobIds = await _service.fetchAppliedJobIds();

    // Fetch favorite job IDs from the dedicated API endpoint
    final favoriteJobIds = await _service.fetchFavoriteJobIds();

    // Fetch fields of interest from the dedicated API endpoint
    final fieldsOfInterest = await _service.fetchFieldsOfInterest();

    // Update user data with applied job IDs, favorite job IDs, and fields of interest
    return userData.copyWith(
      ownedapplications: appliedJobIds,
      favoriteJobs: favoriteJobIds,
      fieldsOfInterest: fieldsOfInterest,
    );
  }

  Future<void> updateName(String value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateName(value);
      return state.value!.copyWith(name: value);
    });
  }

  Future<void> updateEmail(String value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateEmail(value);
      return state.value!.copyWith(email: value);
    });
  }

  Future<void> updatePhone(String value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updatePhone(value);
      return state.value!.copyWith(number: value);
    });
  }

  Future<void> updateCountry(String value) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateCountry(value);
      return state.value!.copyWith(country: value);
    });
  }

  Future<void> toggleFavoriteJob(String jobId) async {
    final intId = int.tryParse(jobId);
    if (intId == null) return;
    final current = state.value;
    if (current == null) return;

    final currentFavs = List<int>.from(current.favoriteJobs);
    final isFav = currentFavs.contains(intId);
    final updatedFavs = isFav
        ? (currentFavs..remove(intId))
        : (currentFavs..add(intId));

    // Optimistic update
    state = AsyncValue.data(
      current.copyWith(favoriteJobs: List<int>.from(updatedFavs)),
    );
    try {
      await _service.updateFavoriteJobs(updatedFavs);
      ref.invalidate(favoriteJobsProvider);
    } catch (e) {
      state = AsyncValue.data(current);
      rethrow;
    }
  }

  /// Check if the user has already applied to a job by job ID
  bool hasApplied(int jobId) {
    final current = state.value;
    if (current == null) return false;
    return current.ownedapplications.contains(jobId);
  }

  /// Refresh applied job IDs by fetching from the API
  /// Call this after applying to a new job or after application status changes
  Future<void> refreshAppliedJobs() async {
    final current = state.value;
    if (current == null) return;

    try {
      final appliedJobIds = await _service.fetchAppliedJobIds();
      state = AsyncValue.data(
        current.copyWith(ownedapplications: appliedJobIds),
      );
    } catch (e) {
      debugPrint('Failed to refresh applied jobs: $e');
      // Don't update state on error, keep current data
    }
  }

  /// Refresh fields of interest by fetching updated user data
  Future<void> refreshFieldsOfInterest() async {
    try {
      final updatedUser = await _service.fetchUserData();
      state = AsyncValue.data(updatedUser);
    } catch (e) {
      debugPrint('Failed to refresh fields of interest: $e');
      // Don't update state on error, keep current data
    }
  }

  /// Refresh only the list of fields of interest using the dedicated endpoint.
  Future<void> refreshOnlyFieldsOfInterest() async {
    final current = state.value;
    if (current == null) return;

    try {
      final fields = await _service.fetchFieldsOfInterest();
      state = AsyncValue.data(current.copyWith(fieldsOfInterest: fields));
    } catch (e) {
      debugPrint('Failed to refresh only fields of interest: $e');
      // keep current state on error
    }
  }

  void updateUserData(PersonalInformationModel userData) {
    state = AsyncValue.data(userData);
  }

  Future<void> updateFieldsOfInterest({
    required List<String> added,
    required List<String> removed,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateFieldsOfInterest(
        fieldsOfInterestToAdd: added,
        fieldsOfInterestToRemove: removed,
      );

      final current = state.value!;
      final newInterests = List<String>.from(current.fieldsOfInterest ?? []);
      newInterests.removeWhere((i) => removed.contains(i));
      newInterests.addAll(added);

      return current.copyWith(fieldsOfInterest: newInterests);
    });
  }

  Future<void> updateWantsEmails(bool wantsEmails) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _service.updateWantsEmails(wantsEmails);
      return state.value!.copyWith(wantsEmails: wantsEmails);
    });
  }
}
