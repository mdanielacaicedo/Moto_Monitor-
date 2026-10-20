class Mantenimiento {
  final String id;
  final String motoId;
  final DateTime fecha;
  final int kilometraje;
  final String tipo;
  final String descripcion;
  final double costo;
  final String? taller;
  final String? tecnico;
  final List<String> trabajosRealizados;
  final List<String> repuestosUsados;
  final int intervaloRecomendado;
  final String? observaciones;
  final bool completado;

  const Mantenimiento({
    required this.id,
    required this.motoId,
    required this.fecha,
    required this.kilometraje,
    required this.tipo,
    required this.descripcion,
    required this.costo,
    this.taller,
    this.tecnico,
    this.trabajosRealizados = const [],
    this.repuestosUsados = const [],
    this.intervaloRecomendado = 5000,
    this.observaciones,
    this.completado = true,
  });

  int get proximoKilometraje => kilometraje + intervaloRecomendado;
  bool get esPreventivo => tipo.toLowerCase().contains('preventivo');
  bool get esCorrectivo => tipo.toLowerCase().contains('correctivo');

  Mantenimiento copyWith({
    String? id,
    String? motoId,
    DateTime? fecha,
    int? kilometraje,
    String? tipo,
    String? descripcion,
    double? costo,
    String? taller,
    String? tecnico,
    List<String>? trabajosRealizados,
    List<String>? repuestosUsados,
    int? intervaloRecomendado,
    String? observaciones,
    bool? completado,
  }) {
    return Mantenimiento(
      id: id ?? this.id,
      motoId: motoId ?? this.motoId,
      fecha: fecha ?? this.fecha,
      kilometraje: kilometraje ?? this.kilometraje,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      costo: costo ?? this.costo,
      taller: taller ?? this.taller,
      tecnico: tecnico ?? this.tecnico,
      trabajosRealizados: trabajosRealizados ?? this.trabajosRealizados,
      repuestosUsados: repuestosUsados ?? this.repuestosUsados,
      intervaloRecomendado: intervaloRecomendado ?? this.intervaloRecomendado,
      observaciones: observaciones ?? this.observaciones,
      completado: completado ?? this.completado,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motoId': motoId,
      'fecha': fecha.toIso8601String(),
      'kilometraje': kilometraje,
      'tipo': tipo,
      'descripcion': descripcion,
      'costo': costo,
      'taller': taller,
      'tecnico': tecnico,
      'trabajosRealizados': trabajosRealizados,
      'repuestosUsados': repuestosUsados,
      'intervaloRecomendado': intervaloRecomendado,
      'observaciones': observaciones,
      'completado': completado,
    };
  }

  factory Mantenimiento.fromJson(Map<String, dynamic> json) {
    try {
      return Mantenimiento(
        id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        motoId: json['motoId']?.toString() ?? '',
        fecha: _parseDateTimeSafe(json['fecha']) ?? DateTime.now(),
        kilometraje: _parseIntSafe(json['kilometraje']) ?? 0,
        tipo: json['tipo']?.toString() ?? 'Mantenimiento',
        descripcion: json['descripcion']?.toString() ?? '',
        costo: _parseDoubleSafe(json['costo']) ?? 0.0,
        taller: json['taller']?.toString(),
        tecnico: json['tecnico']?.toString(),
        trabajosRealizados: _parseListSafe(json['trabajosRealizados']),
        repuestosUsados: _parseListSafe(json['repuestosUsados']),
        intervaloRecomendado: _parseIntSafe(json['intervaloRecomendado']) ?? 5000,
        observaciones: json['observaciones']?.toString(),
        completado: json['completado'] as bool? ?? true,
      );
    } catch (e) {
      return Mantenimiento(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        motoId: '',
        fecha: DateTime.now(),
        kilometraje: 0,
        tipo: 'Mantenimiento',
        descripcion: 'Error al cargar mantenimiento',
        costo: 0.0,
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

  static double? _parseDoubleSafe(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
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

  static List<String> _parseListSafe(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e?.toString() ?? '').toList();
    return [];
  }
}