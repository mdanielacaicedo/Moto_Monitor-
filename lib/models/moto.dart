class Moto {
  final String id;
  final String marca;
  final String modelo;
  final int ano;
  final String placa;
  final int kilometraje;
  final DateTime fechaCompra;
  final DateTime fechaUltimaActualizacion;
  final String? color;
  final String? motor;
  final String? observaciones;

  const Moto({
    required this.id,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.placa,
    required this.kilometraje,
    required this.fechaCompra,
    required this.fechaUltimaActualizacion,
    this.color,
    this.motor,
    this.observaciones,
  });

  Moto copyWith({
    String? id,
    String? marca,
    String? modelo,
    int? ano,
    String? placa,
    int? kilometraje,
    DateTime? fechaCompra,
    DateTime? fechaUltimaActualizacion,
    String? color,
    String? motor,
    String? observaciones,
  }) {
    return Moto(
      id: id ?? this.id,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      ano: ano ?? this.ano,
      placa: placa ?? this.placa,
      kilometraje: kilometraje ?? this.kilometraje,
      fechaCompra: fechaCompra ?? this.fechaCompra,
      fechaUltimaActualizacion: fechaUltimaActualizacion ?? this.fechaUltimaActualizacion,
      color: color ?? this.color,
      motor: motor ?? this.motor,
      observaciones: observaciones ?? this.observaciones,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'marca': marca,
      'modelo': modelo,
      'ano': ano,
      'placa': placa,
      'kilometraje': kilometraje,
      'fechaCompra': fechaCompra.toIso8601String(),
      'fechaUltimaActualizacion': fechaUltimaActualizacion.toIso8601String(),
      'color': color,
      'motor': motor,
      'observaciones': observaciones,
    };
  }

  factory Moto.fromJson(Map<String, dynamic> json) {
    try {
      return Moto(
        id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        marca: json['marca']?.toString() ?? 'Sin configurar',
        modelo: json['modelo']?.toString() ?? 'Sin configurar',
        ano: _parseIntSafe(json['ano']) ?? DateTime.now().year,
        placa: json['placa']?.toString() ?? '',
        kilometraje: _parseIntSafe(json['kilometraje']) ?? 0,
        fechaCompra: _parseDateTimeSafe(json['fechaCompra']) ?? DateTime.now(),
        fechaUltimaActualizacion: _parseDateTimeSafe(json['fechaUltimaActualizacion']) ?? DateTime.now(),
        color: json['color']?.toString(),
        motor: json['motor']?.toString(),
        observaciones: json['observaciones']?.toString(),
      );
    } catch (e) {
      return Moto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        marca: 'Sin configurar',
        modelo: 'Sin configurar',
        ano: DateTime.now().year,
        placa: '',
        kilometraje: 0,
        fechaCompra: DateTime.now(),
        fechaUltimaActualizacion: DateTime.now(),
      );
    }
  }

  static int? _parseIntSafe(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static DateTime? _parseDateTimeSafe(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
