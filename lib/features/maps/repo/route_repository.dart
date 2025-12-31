import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import '../data/models/route_model.dart';

class RouteRepository {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://router.project-osrm.org/route/v1/driving';

  Future<List<RouteModel>> getRoutes(LatLng start, LatLng end) async {
    try {
      final String url = '$_baseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson&alternatives=3';

      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> routesJson = response.data['routes'];
        return routesJson.map((json) => RouteModel.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load routes');
      }
    } on DioException catch (e) {
      print('Error fetching routes: ${e.response?.data}');
      throw Exception('Error fetching routes: ${e.response?.data}');
    } catch (e) {
      throw Exception('Error fetching routes: $e');
    }
  }
}
