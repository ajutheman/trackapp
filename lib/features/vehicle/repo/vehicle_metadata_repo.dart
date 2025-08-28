import '../../../core/constants/api_endpoints.dart';
import '../../../services/network/api_service.dart';
import '../model/vehicle_metadata.dart';

class VehicleMetaRepository {
  final ApiService apiService;

  VehicleMetaRepository({required this.apiService});

  Future<List<VehicleType>> getAllVehicleTypes() async {
    final res = await apiService.get(ApiEndpoints.allVehicleTypes);
    if (res.isSuccess) {
      final List<dynamic> data = res.data;
      return data.map((json) => VehicleType.fromJson(json)).toList();
    } else {
      throw Exception(res.message ?? 'Failed to fetch vehicle types');
    }
  }

  Future<List<VehicleBodyType>> getAllVehicleBodyTypes() async {
    final res = await apiService.get(ApiEndpoints.allVehicleBodyTypes);
    if (res.isSuccess) {
      final List<dynamic> data = res.data;
      return data.map((json) => VehicleBodyType.fromJson(json)).toList();
    } else {
      throw Exception(res.message ?? 'Failed to fetch vehicle body types');
    }
  }

  Future<List<GoodsAccepted>> getAllGoodsAccepted() async {
    final res = await apiService.get(ApiEndpoints.allGoodsAccepted);
    if (res.isSuccess) {
      final List<dynamic> data = res.data;
      return data.map((json) => GoodsAccepted.fromJson(json)).toList();
    } else {
      throw Exception(res.message ?? 'Failed to fetch accepted goods');
    }
  }
}
