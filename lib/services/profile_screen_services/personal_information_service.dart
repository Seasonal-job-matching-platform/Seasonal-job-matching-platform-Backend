import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_seeker/core/dio_provider.dart';
import 'package:job_seeker/core/auth/auth_storage.dart';
import 'package:job_seeker/endpoints.dart';
import 'package:job_seeker/models/profile_screen_models/personal_information_model.dart';

final personalInformationServiceProvider = Provider<PersonalInformationService>(
  (ref) {
    final dio = ref.watch(dioProvider);
    return PersonalInformationService(dio);
  },
);

class PersonalInformationService {
  final Dio _dio;
  final AuthStorage _authStorage = AuthStorage();

  PersonalInformationService(this._dio);

  /// Get the current user ID from storage, or throw an error if not found
  Future<String> _getUserId() async {
    final userId = await _authStorage.getUserId();
    if (userId == null) {
      throw Exception('User ID not found. Please login again.');
    }
    return userId;
  }

  Future<PersonalInformationModel> fetchUserData() async {
    final userId = await _getUserId();
    final userPath = userById(userId);
    final response = await _dio.get(userPath);
    print('Profile API response: ${response.data}');
    // final fixed = Map<String, dynamic>.from(response.data);
    // if (fixed['id'] != null && fixed['id'] is! String) fixed['id'] = fixed['id'].toString();
    try {
      return PersonalInformationModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateName(String vlaue) async {
    final userId = await _getUserId();
    final editPath = editUserById(userId);
    try {
      await _dio.patch(editPath, data: {'name': vlaue});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateEmail(String vlaue) async {
    final userId = await _getUserId();
    final editPath = editUserById(userId);
    try {
      await _dio.patch(editPath, data: {'email': vlaue});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updatePhone(String vlaue) async {
    final userId = await _getUserId();
    final editPath = editUserById(userId);
    try {
      await _dio.patch(editPath, data: {'number': vlaue});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateCountry(String vlaue) async {
    final userId = await _getUserId();
    final editPath = editUserById(userId);
    try {
      await _dio.patch(editPath, data: {'country': vlaue});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateFavoriteJobs(List<int> favoriteJobs) async {
    final userId = await _getUserId();
    final editPath = editUserById(userId);
    try {
      await _dio.patch(editPath, data: {'favoriteJobIds': favoriteJobs});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch the list of job IDs that the user has applied for
  Future<List<int>> fetchAppliedJobIds() async {
    final userId = await _getUserId();
    final appliedJobsPath = getUserAppliedJobs(userId);
    try {
      final response = await _dio.get(appliedJobsPath);
      // The API returns a response with 'jobIds' field
      final jobIds = (response.data['jobIds'] as List)
          .map((id) => id is int ? id : int.parse(id.toString()))
          .toList();
      return jobIds;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch the list of favorite job IDs for the current user
  /// Uses GET /users/:id/favorite-jobs endpoint
  Future<List<int>> fetchFavoriteJobIds() async {
    final userId = await _getUserId();
    final favoritesPath = getUserFavoriteJobs(userId);
    try {
      final response = await _dio.get(favoritesPath);
      // The API returns a list of job IDs
      final data = response.data;
      if (data is List) {
        return data
            .map((id) => id is int ? id : int.parse(id.toString()))
            .toList();
      } else if (data is Map && data['jobIds'] != null) {
        return (data['jobIds'] as List)
            .map((id) => id is int ? id : int.parse(id.toString()))
            .toList();
      } else if (data is Map && data['favoriteJobIds'] != null) {
        return (data['favoriteJobIds'] as List)
            .map((id) => id is int ? id : int.parse(id.toString()))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch only the fields of interest for the current user.
  /// Expected response shape:
  /// {
  ///   "fieldsOfInterest": ["Hospitality", "Ski Instruction"]
  /// }
  Future<List<String>> fetchFieldsOfInterest() async {
    final userId = await _getUserId();
    // Endpoint provided by backend: /users/FOI/:id
    final path = '/users/FOI/$userId';
    try {
      final response = await _dio.get(path);
      final raw = response.data;
      final list =
          (raw['fieldsOfInterest'] as List?)
              ?.map((e) => e == null ? '' : e.toString())
              .where((s) => s.isNotEmpty)
              .toList() ??
          <String>[];
      return list;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update fields of interest by adding and removing interests
  Future<void> updateFieldsOfInterest({
    required List<String> fieldsOfInterestToAdd,
    required List<String> fieldsOfInterestToRemove,
  }) async {
    final userId = await _getUserId();
    final editPath = editUserById(userId);
    try {
      await _dio.patch(
        editPath,
        data: {
          'fieldsOfInterestToAdd': fieldsOfInterestToAdd,
          'fieldsOfInterestToRemove': fieldsOfInterestToRemove,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 400) return 'Invalid data provided.';
        if (statusCode == 401) return 'Unauthorized. Please login again.';
        if (statusCode == 404) return 'Resource not found.';
        if (statusCode == 500) return 'Server error. Please try again later.';
        return 'Something went wrong. Please try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        return 'No internet connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  Future<void> updateWantsEmails(bool wantsEmails) async {
    final userId = await _getUserId();
    final editPath = editUserById(userId);
    try {
      await _dio.patch(editPath, data: {'wantsEmails': wantsEmails.toString()});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
