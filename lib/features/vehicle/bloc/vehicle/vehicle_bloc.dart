import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/constants/upload_image_type.dart';
import 'package:truck_app/features/auth/repo/image_upload_repo.dart';
import 'package:truck_app/model/network/result.dart';

import '../../repo/vehicle_repo.dart';
import 'vehicle_event.dart'; // Import vehicle events
import 'vehicle_state.dart'; // Import vehicle states

/// BLoC for managing vehicle-related states and events.
class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository repository;
  final ImageUploadRepository imageRepository;

  /// Constructor for VehicleBloc.
  /// Initializes the BLoC with VehicleInitial state and registers event handlers.
  VehicleBloc({required this.repository, required this.imageRepository}) : super(VehicleInitial()) {
    on<RegisterVehicle>(_onRegisterVehicle);on<GetVehicles>(_onGetVehicles);
  }

  /// Event handler for the [RegisterVehicle] event.
  ///
  /// Emits [VehicleRegistrationLoading] state, calls the repository to register
  /// the vehicle, saves the access token if available, and then emits
  /// [VehicleRegistrationSuccess] or [VehicleRegistrationFailure] based on the result.
  void _onRegisterVehicle(RegisterVehicle event, Emitter<VehicleState> emit) async {
    emit(VehicleRegistrationLoading());

    try {
      // 1. Upload the single registration certificate image.
      final Result<String> certificateUploadResult = await imageRepository.uploadDocument(type: UploadImageType.registration, imageFile: event.registrationCertificate);

      // Check if the single image upload failed.
      if (!certificateUploadResult.isSuccess) {
        emit(VehicleRegistrationFailure(certificateUploadResult.message ?? 'Failed to upload registration certificate.'));
        return; // Stop execution if upload fails.
      }
      final Result<String> drivingLicenseResult = await imageRepository.uploadDocument(type: UploadImageType.license, imageFile: event.drivingLicense);

      // Check if the single image upload failed.
      if (!certificateUploadResult.isSuccess) {
        emit(VehicleRegistrationFailure(certificateUploadResult.message ?? 'Failed to upload drivingLicense.'));
        return; // Stop execution if upload fails.
      }

      // 2. Upload multiple truck images in parallel.
      final List<Future<Result<String>>> uploadFutures =
          event.truckImages.map((file) {
            return imageRepository.uploadImage(type: UploadImageType.vehicle, imageFile: file);
          }).toList();

      final List<Result<String>> truckUploadResults = await Future.wait(uploadFutures);

      // Check if any of the multiple image uploads failed.
      final List<String> truckImageUrls = [];
      for (final result in truckUploadResults) {
        if (!result.isSuccess) {
          emit(VehicleRegistrationFailure(result.message ?? 'Failed to upload one or more truck images.'));
          return; // Stop execution if any upload fails.
        }
        truckImageUrls.add(result.data!);
      }

      final result = await repository.registerVehicle(
        vehicleNumber: event.vehicleNumber,
        vehicleType: event.vehicleType,
        vehicleBodyType: event.vehicleBodyType,
        vehicleCapacity: event.vehicleCapacity,
        goodsAccepted: event.goodsAccepted,
        drivingLicense: drivingLicenseResult.data!,
        registrationCertificate: certificateUploadResult.data!,
        truckImages: truckImageUrls,
        termsAndConditionsAccepted: event.termsAndConditionsAccepted,
      );

      if (result.isSuccess) {
        emit(VehicleRegistrationSuccess());
      } else {
        emit(VehicleRegistrationFailure(result.message!));
      }
    } catch (e) {
      // Catch any unexpected errors during the process.
      emit(VehicleRegistrationFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }  /// Event handler for the [GetVehicles] event.
    ///
    /// Emits [VehicleListLoading] state, calls the repository to fetch the list
    /// of vehicles, and then emits [VehicleListSuccess] or [VehicleListFailure]
    /// based on the result.
    void _onGetVehicles(GetVehicles event, Emitter<VehicleState> emit) async {
        emit(VehicleListLoading());
    
        try {
          final result = await repository.getVehicles();
    
          if (result.isSuccess) {
            emit(VehicleListSuccess(result.data!));
          } else {
            emit(VehicleListFailure(result.message!));
          }
        } catch (e) {
          emit(VehicleListFailure('An unexpected error occurred: ${e.toString()}'));
        }
      }
}
