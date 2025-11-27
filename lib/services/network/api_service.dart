import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../model/network/result.dart';
import '../local/local_services.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));

  final List<int> successStatusCodes = [200, 201, 202, 204];

  Future<Result<dynamic>> get<T>(String endpoint, {bool isTokenRequired = true, Map<String, dynamic>? queryParams, String? token}) async {
    return _executeRequest(() => _dio.get(endpoint, queryParameters: queryParams), isTokenRequired, token);
  }

  Future<Result<dynamic>> post<T>(String endpoint, {Map<String, dynamic>? body, bool isTokenRequired = true, String? token}) async {
    return _executeRequest(() => _dio.post(endpoint, data: body), isTokenRequired, token);
  }

  Future<Result<dynamic>> postWithFormData<T>(String endpoint, {required Object? formData, bool isTokenRequired = true, String? token}) async {
    return _executeRequest(() => _dio.post(endpoint, data: formData), isTokenRequired, token);
  }

  Future<Result<dynamic>> patch<T>(String endpoint, {Map<String, dynamic>? body, bool isTokenRequired = true, String? token}) async {
    return _executeRequest(() => _dio.patch(endpoint, data: body), isTokenRequired, token);
  }

  Future<Result<dynamic>> put<T>(String endpoint, {Map<String, dynamic>? body, bool isTokenRequired = true, String? token}) async {
    return _executeRequest(() => _dio.put(endpoint, data: body), isTokenRequired, token);
  }

  Future<Result<dynamic>> delete<T>(String endpoint, {bool isTokenRequired = true, String? token}) async {
    return _executeRequest(() => _dio.delete(endpoint), isTokenRequired, token);
  }

  // ---- Private Helpers ---- //
  Future<Result<dynamic>> _executeRequest(Future<Response> Function() requestFn, bool isTokenRequired, String? token) async {
    try {
      await _checkInternetConnection();

      if (isTokenRequired) {
        final _token = await getToken();
        _dio.options.headers['Authorization'] = 'Bearer $_token';
      }

      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      final response = await requestFn();
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    } catch (e) {
      final message = e.toString().contains('No internet connection') ? 'No internet connection. Please check your connection and try again.' : 'Network Error: ${e.toString()}';
      return Result.error(message);
    }
  }

  Future<Result<bool>> _checkInternetConnection() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      throw Exception('No internet connection');
    }
    return Result.success(true);
  }

  Future<String> getToken() async {
    final token = await LocalService.getUserToken();
    if (token == null) {
      throw Exception('Unauthorized: Access token not found');
    }
    return token;
  }

  Future<Result<dynamic>> _handleResponse(Response response) async {
    final data = response.data;

    if (successStatusCodes.contains(response.statusCode)) {
      if (data is Map && (data['status'] == true || data['success'] == true)) {
        return Result.success(data['data'], message: data['message']);
      }
      // Handle validation errors even in success status codes
      final errorMessage = _extractErrorMessage(data);
      return Result.error(errorMessage);
    }

    // Handle error responses
    final errorMessage = _extractErrorMessage(data, response.statusCode);
    return Result.error(errorMessage);
  }

  Result<dynamic> _handleError(DioException e) {
    print(e.response?.data);
    try {
      final data = e.response?.data;
      final errorMessage = _extractErrorMessage(data, e.response?.statusCode);
      return Result.error(errorMessage);
    } catch (exceptionError) {
      return Result.error('Network Parse Error: $exceptionError');
    }
  }

  /// Extract error message from response data, combining validation errors if present
  String _extractErrorMessage(dynamic data, [int? statusCode]) {
    if (data is! Map) {
      return statusCode != null ? 'HTTP Error: $statusCode' : 'Unknown error';
    }

    // Get main message
    String mainMessage = data['message'] ?? (statusCode != null ? 'HTTP Error: $statusCode' : 'Unknown error');

    // If there are validation errors, combine them with the main message
    final errorsData = data['errors'];
    if (errorsData != null) {
      List<String> errorMessages = [];
      
      if (errorsData is List) {
        // Handle list format: [{field: "email", message: "Invalid email"}]
        for (var error in errorsData) {
          if (error is Map) {
            final errorMsg = error['message'] ?? '';
            if (errorMsg.isNotEmpty) {
              errorMessages.add(errorMsg);
            }
          }
        }
      } else if (errorsData is Map) {
        // Handle map format: {email: "Invalid email", password: "Too short"}
        errorsData.forEach((key, value) {
          if (value is String) {
            errorMessages.add(value);
          } else if (value is List) {
            // Handle array of messages per field
            for (var msg in value) {
              if (msg is String && msg.isNotEmpty) {
                errorMessages.add(msg);
              }
            }
          }
        });
      }

      if (errorMessages.isNotEmpty) {
        // Combine main message with validation errors
        if (errorMessages.length == 1) {
          return errorMessages.first;
        } else {
          return '$mainMessage\n\n${errorMessages.join('\n')}';
        }
      }
    }

    return mainMessage;
  }
}