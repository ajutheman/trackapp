import '../../../core/constants/api_endpoints.dart';
import '../../../model/network/result.dart';
import '../../../services/network/api_service.dart';

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
    required String registrationCertificate,
    required List<String> truckImages,
    required bool termsAndConditionsAccepted,
  }) async {   ({
    "vehicleNumber": vehicleNumber,
    "vehicleType": vehicleType,
    "vehicleBodyType": vehicleBodyType,
    "vehicleCapacity": vehicleCapacity,
    "goodsAccepted": goodsAccepted,
    "registrationCertificate": registrationCertificate,
    "truckImages": truckImages,
    "termsAndConditionsAccepted": termsAndConditionsAccepted.toString(), // API expects string
  }).forEach((key, value) {
    print('$key: $value');
  });
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

// You can add more methods here for fetching, updating, or deleting vehicles
// similar to the commented-out methods in user_repo.dart if needed.
}
