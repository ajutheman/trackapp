import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truck_app/core/constants/upload_image_type.dart';

import '../../repo/image_upload_repo.dart'; // Import the new image upload repository
import 'image_upload_event.dart'; // Import image upload events
import 'image_upload_state.dart'; // Import image upload states

/// BLoC for managing image upload states and events.
class ImageUploadBloc extends Bloc<ImageUploadEvent, ImageUploadState> {
  final ImageUploadRepository repository;

  /// Constructor for ImageUploadBloc.
  /// Initializes the BLoC with ImageUploadInitial state and registers event handlers.
  ImageUploadBloc({required this.repository}) : super(ImageUploadInitial()) {
    on<UploadImage>(_onUploadImage);
  }

  /// Event handler for the [UploadImage] event.
  ///
  /// Emits [ImageUploadLoading] state, calls the repository to upload
  /// the image, and then emits [ImageUploadSuccess] or [ImageUploadFailure]
  /// based on the result.
  void _onUploadImage(UploadImage event, Emitter<ImageUploadState> emit) async {
    emit(ImageUploadLoading());
    final result = await repository.uploadImage(
      type: UploadImageType.vehicle,
      imageFile: event.imageFile,
    );

    if (result.isSuccess) {
      // Assuming the API returns a URL or ID for the uploaded image
      final imageUrl = result.data ?? ''; // Adjust key as per your API response
      emit(ImageUploadSuccess(imageUrl: imageUrl));
    } else {
      emit(ImageUploadFailure(result.message!));
    }
  }
}
