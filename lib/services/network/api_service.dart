import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../model/network/result.dart';
import '../local/local_services.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl, headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'x-client-type': 'mobile'}));

  final List<int> successStatusCodes = [200, 201, 202, 204];

  Future<Result<dynamic>> get<T>(String endpoint, {bool isTokenRequired = true, Map<String, dynamic>? queryParams,String? token}) async {
    return _executeRequest(() => _dio.get(endpoint, queryParameters: queryParams), isTokenRequired,token);
  }

  Future<Result<dynamic>> post<T>(String endpoint, {Map<String, dynamic>? body, bool isTokenRequired = true,String? token}) async {
    return _executeRequest(() => _dio.post(endpoint, data: body), isTokenRequired,token);
  }

  Future<Result<dynamic>> patch<T>(String endpoint, {Map<String, dynamic>? body, bool isTokenRequired = true,String? token}) async {
    return _executeRequest(() => _dio.patch(endpoint, data: body), isTokenRequired,token);
  }

  Future<Result<dynamic>> put<T>(String endpoint, {Map<String, dynamic>? body, bool isTokenRequired = true,String? token}) async {
    return _executeRequest(() => _dio.put(endpoint, data: body), isTokenRequired,token);
  }

  Future<Result<dynamic>> delete<T>(String endpoint, {bool isTokenRequired = true,String? token}) async {
    return _executeRequest(() => _dio.delete(endpoint), isTokenRequired,token);
  }

  // ---- Private Helpers ---- //
  Future<Result<dynamic>> _executeRequest(Future<Response> Function() requestFn, bool isTokenRequired,String? token) async {
    try {
      await _checkInternetConnection();

      if (isTokenRequired) {
        final _token = await getToken();
        _dio.options.headers['Authorization'] = 'Bearer $_token';
      }

      if (token!=null) {
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
      if (data['status'] == true || data['success'] == true) {
        return Result.success(data['data'], message: data['message']);
      }
      return Result.error(data['message'] ?? 'Unknown error');
    }

    return Result.error(data['message'] ?? 'HTTP Error: ${response.statusCode}');
  }

  Result<dynamic> _handleError(DioException e) {
    print(e.response?.data);
    try {
      final data = e.response?.data;
      final message = data?['message'] ?? 'HTTP Error: ${e.response?.statusCode}';
      return Result.error(message);
    } catch (exceptionError) {
      return Result.error('Network Parse Error: $exceptionError');
    }
  }
}
