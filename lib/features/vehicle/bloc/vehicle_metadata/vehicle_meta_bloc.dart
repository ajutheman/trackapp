import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/vehicle_metadata.dart';
import '../../repo/vehicle_metadata_repo.dart';
import 'vehicle_meta_event.dart';
import 'vehicle_meta_state.dart';

class VehicleMetaBloc extends Bloc<VehicleMetaEvent, VehicleMetaState> {
  final VehicleMetaRepository repository;

  VehicleMetaBloc({required this.repository}) : super(VehicleMetaInitial()) {
    on<LoadAllMeta>(_onLoadAllMeta);
    on<RefreshMeta>(_onRefreshMeta);
  }

  Future<void> _onLoadAllMeta(LoadAllMeta event, Emitter<VehicleMetaState> emit) async {
    emit(VehicleMetaLoading());
    try {
      final results = await Future.wait([repository.getAllVehicleTypes(), repository.getAllVehicleBodyTypes(), repository.getAllGoodsAccepted()]);

      emit(VehicleMetaLoaded(vehicleTypes: results[0] as List<VehicleType>, bodyTypes: results[1] as List<VehicleBodyType>, goodsAccepted: results[2] as List<GoodsAccepted>));
    } catch (e) {
      emit(VehicleMetaError('Failed to load metadata: $e'));
    }
  }

  Future<void> _onRefreshMeta(RefreshMeta event, Emitter<VehicleMetaState> emit) async {
    // Simple refresh: re-use same handler
    await _onLoadAllMeta(LoadAllMeta(), emit);
  }
}
