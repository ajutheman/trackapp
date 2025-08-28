import 'package:equatable/equatable.dart';

import '../../model/vehicle_metadata.dart';

abstract class VehicleMetaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VehicleMetaInitial extends VehicleMetaState {}

class VehicleMetaLoading extends VehicleMetaState {}

class VehicleMetaLoaded extends VehicleMetaState {
  final List<VehicleType> vehicleTypes;
  final List<VehicleBodyType> bodyTypes;
  final List<GoodsAccepted> goodsAccepted;

  VehicleMetaLoaded({required this.vehicleTypes, required this.bodyTypes, required this.goodsAccepted});

  @override
  List<Object?> get props => [vehicleTypes, bodyTypes, goodsAccepted];
}
class VehicleMetaError extends VehicleMetaState {
  final String message;
  VehicleMetaError(this.message);


  @override
  List<Object?> get props => [message];
}