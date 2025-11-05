import '../../../core/constants/api_endpoints.dart';
import '../../../model/network/result.dart';
import '../../../services/network/api_service.dart';
import '../model/profile.dart';

/// Repository class for handling profile-related API calls.
class ProfileRepository {
  final ApiService apiService;

  /// Constructor for ProfileRepository.
  ProfileRepository({required this.apiService});

  /// Fetches the current user's profile with complete information.
  ///
  /// Returns a [Result] containing a [Profile] object on success,
  /// or an error message on failure.
  Future<Result<Profile>> getProfile() async {
    final result = await apiService.get(ApiEndpoints.getProfile, isTokenRequired: true);

    if (result.isSuccess) {
      try {
        final Map<String, dynamic> profileData = result.data is Map
            ? result.data as Map<String, dynamic>
            : {};

        final Profile profile = Profile.fromJson(profileData);
        return Result.success(profile);
      } catch (e) {
        return Result.error('Failed to parse profile data: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to fetch profile');
    }
  }

  /// Updates the current user's profile information.
  ///
  /// Only the fields that are provided will be updated.
  /// Returns a [Result] containing the updated [Profile] object on success,
  /// or an error message on failure.
  Future<Result<Profile>> updateProfile({
    String? name,
    String? email,
    String? whatsappNumber,
    String? profilePictureId,
  }) async {
    final body = <String, dynamic>{};

    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (whatsappNumber != null) body['whatsappNumber'] = whatsappNumber;
    if (profilePictureId != null) body['profilePicture'] = profilePictureId;

    if (body.isEmpty) {
      return Result.error('At least one field must be provided for update');
    }

    final result = await apiService.put(
      ApiEndpoints.updateProfile,
      body: body,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      try {
        final Map<String, dynamic> profileData = result.data is Map
            ? result.data['user'] ?? result.data
            : {};

        final Profile profile = Profile.fromJson(profileData);
        return Result.success(profile);
      } catch (e) {
        return Result.error('Failed to parse updated profile: ${e.toString()}');
      }
    } else {
      return Result.error(result.message ?? 'Failed to update profile');
    }
  }

  /// Deletes the current user's account (soft delete).
  ///
  /// Returns a [Result] containing a boolean indicating success,
  /// or an error message on failure.
  Future<Result<bool>> deleteAccount() async {
    final result = await apiService.delete(
      ApiEndpoints.deleteProfile,
      isTokenRequired: true,
    );

    if (result.isSuccess) {
      return Result.success(true);
    } else {
      return Result.error(result.message ?? 'Failed to delete account');
    }
  }
}

