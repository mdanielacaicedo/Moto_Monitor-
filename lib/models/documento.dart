class Documento {
  final String id;
  final String motoId;
  final String tipo;
  final String numero;
  final DateTime fechaExpedicion;
  final DateTime fechaVencimiento;
  final String entidadExpedidora;
  final String? observaciones;
  final bool activo;

  const Documento({
    required this.id,
    required this.motoId,
    required this.tipo,
    required this.numero,
    required this.fechaExpedicion,
    required this.fechaVencimiento,
    required this.entidadExpedidora,
    this.observaciones,
    this.activo = true,
  });

  Duration get tiempoRestante => fechaVencimiento.difference(DateTime.now());
  int get diasRestantes => tiempoRestante.inDays;
  bool get vencido => DateTime.now().isAfter(fechaVencimiento);
  bool get proximoAVencer => !vencido && diasRestantes <= 30;
  bool get venceHoy => !vencido && diasRestantes == 0;

  String get estadoTexto {
    if (vencido) return 'Vencido';
    if (venceHoy) return 'Vence hoy';
    if (proximoAVencer) return 'Próximo a vencer';
    return 'Vigente';
  }

  Documento copyWith({
    String? id,
    String? motoId,
    String? tipo,
    String? numero,
    DateTime? fechaExpedicion,
    DateTime? fechaVencimiento,
    String? entidadExpedidora,
    String? observaciones,
    bool? activo,
  }) {
    return Documento(
      id: id ?? this.id,
      motoId: motoId ?? this.motoId,
      tipo: tipo ?? this.tipo,
      numero: numero ?? this.numero,
      fechaExpedicion: fechaExpedicion ?? this.fechaExpedicion,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      entidadExpedidora: entidadExpedidora ?? this.entidadExpedidora,
      observaciones: observaciones ?? this.observaciones,
      activo: activo ?? this.activo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'motoId': motoId,
      'tipo': tipo,
      'numero': numero,
      'fechaExpedicion': fechaExpedicion.toIso8601String(),
      'fechaVencimiento': fechaVencimiento.toIso8601String(),
      'entidadExpedidora': entidadExpedidora,
      'observaciones': observaciones,
      'activo': activo,
    };
  }

  factory Documento.fromJson(Map<String, dynamic> json) {
    try {
      return Documento(
        id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
        motoId: json['motoId']?.toString() ?? '',
        tipo: json['tipo']?.toString() ?? 'Documento',
        numero: json['numero']?.toString() ?? '',
        fechaExpedicion: _parseDateTimeSafe(json['fechaExpedicion']) ?? DateTime.now(),
        fechaVencimiento: _parseDateTimeSafe(json['fechaVencimiento']) ?? DateTime.now().add(const Duration(days: 365)),
        entidadExpedidora: json['entidadExpedidora']?.toString() ?? 'Por definir',
        observaciones: json['observaciones']?.toString(),
        activo: json['activo'] as bool? ?? true,
      );
    } catch (e) {
      return Documento(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        motoId: '',
        tipo: 'Documento',
        numero: '',
        fechaExpedicion: DateTime.now(),
        fechaVencimiento: DateTime.now().add(const Duration(days: 365)),
        entidadExpedidora: 'Por definir',
        observaciones: 'Error al cargar documento',
      );
    }
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