// lib/utils/mantenimiento_helper.dart
/// Utilidades y lógica de negocio para mantenimiento de motos
/// Proporciona funciones para cálculos, validaciones y semaforización

/// Enumeración para los estados del semáforo de mantenimiento
enum EstadoSemaforoMantenimiento {
  verde,    // > 15 días restantes
  amarillo, // Entre 7 y 15 días restantes
  rojo,     // < 7 días o vencido
}

/// Clase de utilidad para lógica de mantenimiento
class MantenimientoHelper {
  /// Calcula los días restantes para el próximo mantenimiento
  ///
  /// Parámetros:
  /// - [ultimaFecha]: Fecha del último mantenimiento
  /// - [proximaFecha]: Fecha programada para el próximo mantenimiento
  ///
  /// Retorna: Número de días restantes (negativo si está vencido)
  static int calcularDiasRestantes(DateTime ultimaFecha, DateTime proximaFecha) {
    final ahora = DateTime.now();
    final diferencia = proximaFecha.difference(ahora);
    return diferencia.inDays;
  }

  /// Calcula el kilometraje restante para el próximo mantenimiento
  ///
  /// Parámetros:
  /// - [kilometrajeActual]: Kilómetros actuales de la moto
  /// - [ultimoKilometraje]: Kilómetros en el último mantenimiento
  /// - [intervaloRecomendado]: Intervalo en km para el próximo servicio
  ///
  /// Retorna: Kilómetros restantes (negativo si está vencido)
  static int calcularKilometrajeRestante(
    int kilometrajeActual,
    int ultimoKilometraje,
    int intervaloRecomendado,
  ) {
    final proximoMantenimiento = ultimoKilometraje + intervaloRecomendado;
    return proximoMantenimiento - kilometrajeActual;
  }

  /// Valida si el nuevo kilometraje es válido según el histórico
  /// Regla de negocio: No se puede registrar un km menor al anterior
  ///
  /// Parámetros:
  /// - [nuevoKilometraje]: Nuevo valor de km a registrar
  /// - [ultimoKilometraje]: Km registrado anteriormente
  ///
  /// Retorna: true si es válido, false si viola la regla de negocio
  static bool validarKilometraje(int nuevoKilometraje, int ultimoKilometraje) {
    return nuevoKilometraje >= ultimoKilometraje;
  }

  /// Obtiene el estado del semáforo basado en días restantes
  ///
  /// Estados:
  /// - VERDE: > 15 días restantes (todo está bien)
  /// - AMARILLO: Entre 7 y 15 días restantes (próximo a vencer)
  /// - ROJO: < 7 días o vencido (urgente)
  ///
  /// Parámetros:
  /// - [diasRestantes]: Días restantes para el próximo mantenimiento
  /// - [estaVencido]: True si ya pasó la fecha de vencimiento
  ///
  /// Retorna: Estado del semáforo (VERDE, AMARILLO, ROJO)
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

  /// Obtiene el estado del semáforo basado en kilometraje restante
  ///
  /// Estados:
  /// - VERDE: > 3000 km restantes
  /// - AMARILLO: Entre 1000 y 3000 km restantes
  /// - ROJO: < 1000 km o vencido (negativo)
  ///
  /// Parámetros:
  /// - [kilometrajeRestante]: Km faltantes para el próximo mantenimiento
  /// - [estaVencido]: True si el kilometraje ya fue superado
  ///
  /// Retorna: Estado del semáforo (VERDE, AMARILLO, ROJO)
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

  /// Obtiene el estado combinado considerando TANTO fecha como km
  /// Usa la combinación más conservadora (la peor situación)
  ///
  /// Parámetros:
  /// - [diasRestantes]: Días restantes para el próximo mantenimiento
  /// - [kilometrajeRestante]: Km faltantes para el próximo mantenimiento
  /// - [estaVencidoPorFecha]: True si pasó la fecha límite
  /// - [estaVencidoPorKilometraje]: True si pasó el km límite
  ///
  /// Retorna: Estado del semáforo más crítico
  static EstadoSemaforoMantenimiento obtenerEstadoSemaforoConsolidado(
    int diasRestantes,
    int kilometrajeRestante,
    bool estaVencidoPorFecha,
    bool estaVencidoPorKilometraje,
  ) {
    // Si cualquiera está vencido, es ROJO
    if (estaVencidoPorFecha || estaVencidoPorKilometraje) {
      return EstadoSemaforoMantenimiento.rojo;
    }

    // Obtener estados individuales
    final estadoPorFecha = obtenerEstadoSemaforoProximaFecha(
      diasRestantes,
      estaVencidoPorFecha,
    );
    final estadoPorKm = obtenerEstadoSemaforoProximoKilometraje(
      kilometrajeRestante,
      estaVencidoPorKilometraje,
    );

    // Retornar el estado más crítico (rojo > amarillo > verde)
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

  /// Obtiene una descripción textual del estado del semáforo
  ///
  /// Parámetros:
  /// - [estado]: Estado del semáforo
  ///
  /// Retorna: Descripción amigable del estado
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

  /// Estima la fecha del próximo mantenimiento basada en uso diario
  ///
  /// Parámetros:
  /// - [ultimaFecha]: Fecha del último mantenimiento
  /// - [kilometrajeActual]: Km actuales
  /// - [ultimoKilometraje]: Km del último mantenimiento
  /// - [intervaloRecomendado]: Km recomendados entre servicios
  /// - [kmDiarios]: Promedio de km conducidos por día
  ///
  /// Retorna: Fecha estimada para el próximo mantenimiento
  static DateTime estimarProximaFechaMantenimiento(
    DateTime ultimaFecha,
    int kilometrajeActual,
    int ultimoKilometraje,
    int intervaloRecomendado,
    int kmDiarios,
  ) {
    // Calcular km restantes
    final proximoMantenimiento = ultimoKilometraje + intervaloRecomendado;
    final kmRestantes = proximoMantenimiento - kilometrajeActual;

    // Calcular días faltantes a ese ritmo
    final diasFaltantes = (kmRestantes / kmDiarios).ceil();

    // Sumar a la fecha actual
    return DateTime.now().add(Duration(days: diasFaltantes));
  }
}

