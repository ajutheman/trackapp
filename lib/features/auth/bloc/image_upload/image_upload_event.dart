import 'dart:io'; // Required for File
import 'package:equatable/equatable.dart';

/// Abstract base class for all image upload related events.
abstract class ImageUploadEvent extends Equatable {
  const ImageUploadEvent();

  @override
  List<Object> get props => [];
}

/// Event to trigger the upload of a single image.
class UploadImage extends ImageUploadEvent {
  final File imageFile;
  final String token; // Token passed with the event

  /// Constructor for UploadImage event.
  const UploadImage({
    required this.imageFile,
    required this.token,
  });

  @override
  List<Object> get props => [imageFile, token];
}
