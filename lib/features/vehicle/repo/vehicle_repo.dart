import '../../../core/constants/api_endpoints.dart';
import '../../../model/network/result.dart';
import '../../../services/network/api_service.dart';
import '../model/vehicle.dart';

/// Repository class for handling vehicle-related API calls.
class VehicleRepository {
  final ApiService apiService;

  /// Constructor for VehicleRepository.
  VehicleRepository({required this.apiService});

  /// Registers a new vehicle by making a POST request to the API.
  ///
  /// Takes various vehicle details as parameters and returns a [Result]
  /// indicating success or failure, along with the API response data.
  Future<Result<Map<String, dynamic>>> registerVehicle({
    required String vehicleNumber,
    required String vehicleType,
    required String vehicleBodyType,
    required String vehicleCapacity,
    required String goodsAccepted,
    required String drivingLicense,
    required String registrationCertificate,
    required List<String> truckImages,
    required bool termsAndConditionsAccepted,
  }) async {
    final res = await apiService.post(
      // Assuming you have an API endpoint for vehicle registration
      ApiEndpoints.registerVehicle, // You'll need to define this in ApiEndpoints
      body: {
        "vehicleNumber": vehicleNumber,
        "vehicleType": vehicleType,
        "vehicleBodyType": vehicleBodyType,
        "vehicleCapacity": vehicleCapacity,
        "goodsAccepted": goodsAccepted,
        "registrationCertificate": registrationCertificate,
        "drivingLicense": drivingLicense,
        "truckImages": truckImages,
        "termsAndConditionsAccepted": termsAndConditionsAccepted.toString(), // API expects string
      },
      isTokenRequired: true, // Assuming vehicle registration requires a token
    );

    if (res.isSuccess) {
      return Result.success(res.data as Map<String, dynamic>);
    } else {
      return Result.error(res.message ?? 'Failed to register vehicle');
    }
  }

  Future<Result<List<Vehicle>>> getVehicles() async {
    final res = await apiService.get(ApiEndpoints.getVehicles, isTokenRequired: true);

    if (res.isSuccess) {
      try {
        final List<dynamic> vehicleData = res.data as List<dynamic>;
        final vehicles = vehicleData.map((json) => Vehicle.fromMap(json as Map<String, dynamic>)).toList();
        return Result.success(vehicles);
      } catch (e) {
        print(e);
        return Result.error('Failed to parse vehicle data.');
      }
    } else {
      return Result.error(res.message ?? 'Failed to fetch vehicles');
    }
  }
}
