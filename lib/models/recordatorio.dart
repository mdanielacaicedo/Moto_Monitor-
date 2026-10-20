class Recordatorio {
  final String id;
  final String motoId;
  final String titulo;
  final String descripcion;
  final DateTime fechaCreacion;
  final DateTime fechaVencimiento;
  final String tipo;
  final String prioridad;
  final bool completado;
  final String? accion;
  final Map<String, dynamic>? metadata;

  const Recordatorio({
    required this.id,
    required this.motoId,
    required this.titulo,
    required this.descripcion,
    required this.fechaCreacion,
    required this.fechaVencimiento,
    required this.tipo,
    this.prioridad = 'normal',
    this.completado = false,
    this.accion,
    this.metadata,
  });

  Duration get tiempoRestante => fechaVencimiento.difference(DateTime.now());
  int get diasRestantes => tiempoRestante.inDays;
  bool get vencido => DateTime.now().isAfter(fechaVencimiento);
  bool get esUrgente => prioridad == 'alta' || (!vencido && diasRestantes <= 3);
  bool get esHoy => !vencido && diasRestantes == 0;

  String get estadoTexto {
    if (completado) return 'Completado';
    if (vencido) return 'Vencido';
    if (esHoy) return 'Para hoy';
    if (esUrgente) return 'Urgente';
    return 'Pendiente';
  }

  Recordatorio copyWith({
    String? id,
    String? motoId,
    String? titulo,
    String? descripcion,
    DateTime? fechaCreacion,
    DateTime? fechaVencimiento,
    String? tipo,
    String? prioridad,
    bool? completado,
    String? accion,
    Map<String, dynamic>? metadata,
  }) {
    return Recordatorio(
      id: id ?? this.id,
      motoId: motoId ?? this.motoId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      tipo: tipo ?? this.tipo,
      prioridad: prioridad ?? this.prioridad,
      completado: completado ?? this.completado,
      accion: accion ?? this.accion,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motoId': motoId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'fechaVencimiento': fechaVencimiento.toIso8601String(),
      'tipo': tipo,
      'prioridad': prioridad,
      'completado': completado,
      'accion': accion,
      'metadata': metadata,
    };
  }

  factory Recordatorio.fromJson(Map<String, dynamic> json) {
    try {
      return Recordatorio(
        id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        motoId: json['motoId']?.toString() ?? '',
        titulo: json['titulo']?.toString() ?? 'Recordatorio',
        descripcion: json['descripcion']?.toString() ?? '',
        fechaCreacion: _parseDateTimeSafe(json['fechaCreacion']) ?? DateTime.now(),
        fechaVencimiento: _parseDateTimeSafe(json['fechaVencimiento']) ?? DateTime.now().add(const Duration(days: 1)),
        tipo: json['tipo']?.toString() ?? 'general',
        prioridad: json['prioridad']?.toString() ?? 'normal',
        completado: json['completado'] as bool? ?? false,
        accion: json['accion']?.toString(),
        metadata: _parseMetadata(json['metadata']),
      );
    } catch (e) {
      return Recordatorio(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        motoId: '',
        titulo: 'Recordatorio',
        descripcion: 'Error al cargar recordatorio',
        fechaCreacion: DateTime.now(),
        fechaVencimiento: DateTime.now().add(const Duration(days: 1)),
        tipo: 'general',
      );
    }
  }

  static Map<String, dynamic>? _parseMetadata(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic value) => MapEntry(key.toString(), value));
    }
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
