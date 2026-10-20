enum EstadoSemaforoMantenimiento {
  verde,
  amarillo,
  rojo,
}

class MantenimientoHelper {
  static int calcularDiasRestantes(DateTime ultimaFecha, DateTime proximaFecha) {
    final ahora = DateTime.now();
    final diferencia = proximaFecha.difference(ahora);
    return diferencia.inDays;
  }

  static int calcularKilometrajeRestante(
    int kilometrajeActual,
    int ultimoKilometraje,
    int intervaloRecomendado,
  ) {
    final proximoMantenimiento = ultimoKilometraje + intervaloRecomendado;
    return proximoMantenimiento - kilometrajeActual;
  }

  static bool validarKilometraje(int nuevoKilometraje, int ultimoKilometraje) {
    return nuevoKilometraje >= ultimoKilometraje;
  }

  static EstadoSemaforoMantenimiento obtenerEstadoSemaforoProximaFecha(
    int diasRestantes,
    bool estaVencido,
  ) {
    if (estaVencido || diasRestantes < 7) {
      return EstadoSemaforoMantenimiento.rojo;
    } else if (diasRestantes >= 7 && diasRestantes <= 15) {
      return EstadoSemaforoMantenimiento.amarillo;
    } else {
      return EstadoSemaforoMantenimiento.verde;
    }
  }

  static EstadoSemaforoMantenimiento obtenerEstadoSemaforoProximoKilometraje(
    int kilometrajeRestante,
    bool estaVencido,
  ) {
    if (estaVencido || kilometrajeRestante < 1000) {
      return EstadoSemaforoMantenimiento.rojo;
    } else if (kilometrajeRestante >= 1000 && kilometrajeRestante <= 3000) {
      return EstadoSemaforoMantenimiento.amarillo;
    } else {
      return EstadoSemaforoMantenimiento.verde;
    }
  }

  static EstadoSemaforoMantenimiento obtenerEstadoSemaforoConsolidado(
    int diasRestantes,
    int kilometrajeRestante,
    bool estaVencidoPorFecha,
    bool estaVencidoPorKilometraje,
  ) {
    if (estaVencidoPorFecha || estaVencidoPorKilometraje) {
      return EstadoSemaforoMantenimiento.rojo;
    }

    final estadoPorFecha = obtenerEstadoSemaforoProximaFecha(
      diasRestantes,
      estaVencidoPorFecha,
    );
    final estadoPorKm = obtenerEstadoSemaforoProximoKilometraje(
      kilometrajeRestante,
      estaVencidoPorKilometraje,
    );

    if (estadoPorFecha == EstadoSemaforoMantenimiento.rojo ||
        estadoPorKm == EstadoSemaforoMantenimiento.rojo) {
      return EstadoSemaforoMantenimiento.rojo;
    } else if (estadoPorFecha == EstadoSemaforoMantenimiento.amarillo ||
        estadoPorKm == EstadoSemaforoMantenimiento.amarillo) {
      return EstadoSemaforoMantenimiento.amarillo;
    } else {
      return EstadoSemaforoMantenimiento.verde;
    }
  }

  static String obtenerDescripcionEstado(EstadoSemaforoMantenimiento estado) {
    switch (estado) {
      case EstadoSemaforoMantenimiento.verde:
        return 'Todo está en orden. Próximo mantenimiento dentro de tiempo.';
      case EstadoSemaforoMantenimiento.amarillo:
        return 'Atención: El mantenimiento está próximo a vencer.';
      case EstadoSemaforoMantenimiento.rojo:
        return 'Urgente: El mantenimiento está vencido o por vencer.';
    }
  }

  static DateTime estimarProximaFechaMantenimiento(
    DateTime ultimaFecha,
    int kilometrajeActual,
    int ultimoKilometraje,
    int intervaloRecomendado,
    int kmDiarios,
  ) {
    final proximoMantenimiento = ultimoKilometraje + intervaloRecomendado;
    final kmRestantes = proximoMantenimiento - kilometrajeActual;
    final diasFaltantes = (kmRestantes / kmDiarios).ceil();

    return DateTime.now().add(Duration(days: diasFaltantes));
  }
}
