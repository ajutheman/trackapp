import 'package:equatable/equatable.dart';

abstract class VehicleMetaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAllMeta extends VehicleMetaEvent {}

class RefreshMeta extends VehicleMetaEvent {}
