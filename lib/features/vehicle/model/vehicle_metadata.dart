class VehicleType {
  final String id;
  final String name;

  VehicleType({required this.id, required this.name});

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    return VehicleType(
      id: json['_id'] as String,
      name: json['name'] as String,
    );
  }

  @override
  String toString() => name;
}

class VehicleBodyType {
  final String id;
  final String name;

  VehicleBodyType({required this.id, required this.name});

  factory VehicleBodyType.fromJson(Map<String, dynamic> json) {
    return VehicleBodyType(
      id: json['_id'] as String,
      name: json['name'] as String,
    );
  }

  @override
  String toString() => name;
}

class GoodsAccepted {
  final String id;
  final String name;

  GoodsAccepted({required this.id, required this.name});

  factory GoodsAccepted.fromJson(Map<String, dynamic> json) {
    return GoodsAccepted(
      id: json['_id'] as String,
      name: json['name'] as String,
    );
  }

  @override
  String toString() => name;
}