import 'package:equatable/equatable.dart';

/// Abstract base class for all image upload related states.
abstract class ImageUploadState extends Equatable {
  const ImageUploadState();

  @override
  List<Object> get props => [];
}

/// Initial state of the ImageUploadBloc.
class ImageUploadInitial extends ImageUploadState {}

/// State indicating that image upload is in progress.
class ImageUploadLoading extends ImageUploadState {}

/// State indicating that image upload was successful.
class ImageUploadSuccess extends ImageUploadState {
  final String imageUrl; // URL of the uploaded image if returned by API

  /// Constructor for ImageUploadSuccess state.
  const ImageUploadSuccess({required this.imageUrl});

  @override
  List<Object> get props => [imageUrl];
}

/// State indicating that image upload failed.
class ImageUploadFailure extends ImageUploadState {
  final String error;

  /// Constructor for ImageUploadFailure state.
  const ImageUploadFailure(this.error);

  @override
  List<Object> get props => [error];
}
