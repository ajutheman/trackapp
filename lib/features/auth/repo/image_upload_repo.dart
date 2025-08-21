import 'dart:io'; // Required for File

import 'package:dio/dio.dart'; // Import Dio for FormData and MultipartFile

import '../../../core/constants/api_endpoints.dart';
import '../../../model/network/result.dart';
import '../../../services/network/api_service.dart';

/// Repository class for handling image upload API calls.
class ImageUploadRepository {
  final ApiService apiService;

  /// Constructor for ImageUploadRepository.
  ImageUploadRepository({required this.apiService});

  /// Uploads a single image file to the API and returns the image ID.
  Future<Result<String>> uploadImage({required File imageFile}) async {
    try {
      // Create a FormData object to hold the file.
      final formData = FormData.fromMap({'type': 'vehicle', 'image': await MultipartFile.fromFile(imageFile.path, filename: imageFile.path.split('/').last)});

      // Use the postWithFormData method from ApiService.
      final res = await apiService.postWithFormData(
        ApiEndpoints.uploadImage, // Ensure you have this endpoint defined.
        formData: formData,
        isTokenRequired: true, // Assuming image upload requires authentication.
      );

      if (res.isSuccess) {
        // The API response data should contain the image ID.
        // Assuming the response data is a Map with a key like 'imageId'.
        // You might need to adjust this based on your API's response structure.
        return Result.success('test');
      } else {
        return Result.error(res.message ?? 'Failed to upload image');
      }
    } catch (e) {
      return Result.error('Error uploading image: ${e.toString()}');
    }
  }
}
