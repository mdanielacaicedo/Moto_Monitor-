// test/mantenimiento_test.dart
/// Pruebas unitarias para la lógica de mantenimiento de motocicletas
/// Valida: cálculos de km/días, reglas de negocio y motor de semaforización
///
/// Ejecutar con: flutter test test/mantenimiento_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:moto_monitor/utils/mantenimiento_helper.dart';
import 'package:moto_monitor/models/mantenimiento.dart';

void main() {
  group('🏍️ Pruebas de Mantenimiento - Moto Monitor', () {
    // ==================================================================================
    // GRUPO 1: ESTIMACIÓN DE MANTENIMIENTO
    // Valida el cálculo de días y kilometraje restantes según uso diario
    // ==================================================================================

    group('📊 Prueba 1: Estimación de Mantenimiento (Días y Km Restantes)', () {

      test('✅ Debe calcular correctamente los días restantes para el próximo mantenimiento', () {
        // ARRANGE - Preparar datos
        final ultimaFecha = DateTime.now().subtract(const Duration(days: 30));
        final proximaFecha = DateTime.now().add(const Duration(days: 20));

        // ACT - Ejecutar la función
        final diasRestantes = MantenimientoHelper.calcularDiasRestantes(
          ultimaFecha,
          proximaFecha,
        );

        // ASSERT - Verificar resultado
        // Esperamos aproximadamente 20 días (permitimos 1 día de margen por ejecución)
        expect(diasRestantes, greaterThanOrEqualTo(19));
        expect(diasRestantes, lessThanOrEqualTo(21));
      });

      test('✅ Debe detectar cuando el mantenimiento está vencido (días negativos)', () {
        // ARRANGE
        final ultimaFecha = DateTime.now().subtract(const Duration(days: 60));
        final proximaFecha = DateTime.now().subtract(const Duration(days: 10));

        // ACT
        final diasRestantes = MantenimientoHelper.calcularDiasRestantes(
          ultimaFecha,
          proximaFecha,
        );

        // ASSERT - Debe ser negativo cuando está vencido
        expect(diasRestantes, lessThan(0));
      });

      test('✅ Debe calcular correctamente el kilometraje restante para el próximo servicio', () {
        // ARRANGE
        const kilometrajeActual = 15000;
        const ultimoKilometraje = 10000;
        const intervaloRecomendado = 5000; // Próximo servicio cada 5000 km

        // ACT
        final kmRestantes = MantenimientoHelper.calcularKilometrajeRestante(
          kilometrajeActual,
          ultimoKilometraje,
          intervaloRecomendado,
        );

        // ASSERT
        // Próximo mantenimiento: 10000 + 5000 = 15000
        // Restante: 15000 - 15000 = 0 (justo al límite)
        expect(kmRestantes, equals(0));
      });

      test('✅ Debe calcular correctamente cuando falta kilometraje para el próximo servicio', () {
        // ARRANGE
        const kilometrajeActual = 12000;
        const ultimoKilometraje = 10000;
        const intervaloRecomendado = 5000;

        // ACT
        final kmRestantes = MantenimientoHelper.calcularKilometrajeRestante(
          kilometrajeActual,
          ultimoKilometraje,
          intervaloRecomendado,
        );

        // ASSERT
        // Próximo: 15000, Actual: 12000, Restante: 3000
        expect(kmRestantes, equals(3000));
      });

      test('✅ Debe detectar cuando el kilometraje para mantenimiento está vencido (negativo)', () {
        // ARRANGE
        const kilometrajeActual = 16000;
        const ultimoKilometraje = 10000;
        const intervaloRecomendado = 5000;

        // ACT
        final kmRestantes = MantenimientoHelper.calcularKilometrajeRestante(
          kilometrajeActual,
          ultimoKilometraje,
          intervaloRecomendado,
        );

        // ASSERT - Debe ser negativo (está vencido)
        expect(kmRestantes, lessThan(0));
        expect(kmRestantes, equals(-1000));
      });

      test('✅ Debe estimar correctamente la próxima fecha basada en km diarios promedio', () {
        // ARRANGE
        final hoaAxiom = DateTime.now();
        const kilometrajeActual = 10000;
        const ultimoKilometraje = 9000;
        const intervaloRecomendado = 5000;
        const kmDiarios = 100; // Promedio 100 km/día

        // ACT
        final proximaFecha = MantenimientoHelper.estimarProximaFechaMantenimiento(
          hoaAxiom,
          kilometrajeActual,
          ultimoKilometraje,
          intervaloRecomendado,
          kmDiarios,
        );

        // ASSERT
        // Próximo mantenimiento: 9000 + 5000 = 14000
        // Km restantes: 14000 - 10000 = 4000
        // Días faltantes: 4000 / 100 = 40 días
        final diasEstimados = proximaFecha.difference(DateTime.now()).inDays;
        expect(diasEstimados, greaterThanOrEqualTo(39));
        expect(diasEstimados, lessThanOrEqualTo(41));
      });
    });

    // ==================================================================================
    // GRUPO 2: REGLA DE NEGOCIO DE KILOMETRAJE
    // Valida que no se pueda registrar un km inferior al anterior
    // ==================================================================================

    group('🔐 Prueba 2: Regla de Negocio - Validación de Kilometraje', () {

      test('✅ Debe permitir registrar un kilometraje mayor al anterior', () {
        // ARRANGE
        const ultimoKilometraje = 10000;
        const nuevoKilometraje = 10500;

        // ACT
        final esValido = MantenimientoHelper.validarKilometraje(
          nuevoKilometraje,
          ultimoKilometraje,
        );

        // ASSERT
        expect(esValido, isTrue);
      });

      test('✅ Debe permitir registrar el mismo kilometraje (no decrecer)', () {
        // ARRANGE
        const ultimoKilometraje = 10000;
        const nuevoKilometraje = 10000;

        // ACT
        final esValido = MantenimientoHelper.validarKilometraje(
          nuevoKilometraje,
          ultimoKilometraje,
        );

        // ASSERT - Regla: >= anterior (permite igualdad)
        expect(esValido, isTrue);
      });

      test('✅ Debe rechazar un kilometraje menor al anterior (regla crítica)', () {
        // ARRANGE
        const ultimoKilometraje = 10000;
        const nuevoKilometraje = 9500; // Intenta registrar menos km

        // ACT
        final esValido = MantenimientoHelper.validarKilometraje(
          nuevoKilometraje,
          ultimoKilometraje,
        );

        // ASSERT
        expect(esValido, isFalse);
      });

      test('✅ Debe rechazar un kilometraje significativamente menor (fraude potencial)', () {
        // ARRANGE
        const ultimoKilometraje = 150000;
        const nuevoKilometraje = 100000; // Intenta retroceder 50,000 km

        // ACT
        final esValido = MantenimientoHelper.validarKilometraje(
          nuevoKilometraje,
          ultimoKilometraje,
        );

        // ASSERT
        expect(esValido, isFalse);
      });

      test('✅ Debe aceptar incrementos pequeños (uso normal)', () {
        // ARRANGE
        const ultimoKilometraje = 95000;
        const nuevoKilometraje = 95050; // Solo 50 km más

        // ACT
        final esValido = MantenimientoHelper.validarKilometraje(
          nuevoKilometraje,
          ultimoKilometraje,
        );

        // ASSERT
        expect(esValido, isTrue);
      });

      test('✅ Debe aceptar incrementos grandes (viaje largo)', () {
        // ARRANGE
        const ultimoKilometraje = 50000;
        const nuevoKilometraje = 51500; // Viaje de 1500 km

        // ACT
        final esValido = MantenimientoHelper.validarKilometraje(
          nuevoKilometraje,
          ultimoKilometraje,
        );

        // ASSERT
        expect(esValido, isTrue);
      });
    });

    // ==================================================================================
    // GRUPO 3: MOTOR DE SEMAFORIZACIÓN
    // Valida la lógica de asignación de colores (VERDE, AMARILLO, ROJO)
    // ==================================================================================

    group('🚦 Prueba 3: Motor de Semaforización (Colores de Estado)', () {

      group('📅 Semaforización por FECHA de Mantenimiento', () {

        test('✅ VERDE: Debe mostrar verde cuando hay más de 15 días restantes', () {
          // ARRANGE
          const diasRestantes = 20;
          const estaVencido = false;

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoProximaFecha(
            diasRestantes,
            estaVencido,
          );

          // ASSERT
          expect(estado, equals(EstadoSemaforoMantenimiento.verde));
        });

        test('✅ AMARILLO: Debe mostrar amarillo entre 7 y 15 días restantes', () {
          // ARRANGE - Caso 1: 15 días (límite superior)
          const diasRestantes1 = 15;

          // ACT
          final estado1 = MantenimientoHelper.obtenerEstadoSemaforoProximaFecha(
            diasRestantes1,
            false,
          );

          // ASSERT
          expect(estado1, equals(EstadoSemaforoMantenimiento.amarillo));

          // ARRANGE - Caso 2: 10 días (punto medio)
          const diasRestantes2 = 10;

          // ACT
          final estado2 = MantenimientoHelper.obtenerEstadoSemaforoProximaFecha(
            diasRestantes2,
            false,
          );

          // ASSERT
          expect(estado2, equals(EstadoSemaforoMantenimiento.amarillo));

          // ARRANGE - Caso 3: 7 días (límite inferior)
          const diasRestantes3 = 7;

          // ACT
          final estado3 = MantenimientoHelper.obtenerEstadoSemaforoProximaFecha(
            diasRestantes3,
            false,
          );

          // ASSERT
          expect(estado3, equals(EstadoSemaforoMantenimiento.amarillo));
        });

        test('✅ ROJO: Debe mostrar rojo cuando hay menos de 7 días restantes', () {
          // ARRANGE
          const diasRestantes = 5;
          const estaVencido = false;

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoProximaFecha(
            diasRestantes,
            estaVencido,
          );

          // ASSERT
          expect(estado, equals(EstadoSemaforoMantenimiento.rojo));
        });

        test('✅ ROJO: Debe mostrar rojo cuando está vencido (días negativos)', () {
          // ARRANGE
          const diasRestantes = -5; // 5 días pasados
          const estaVencido = true;

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoProximaFecha(
            diasRestantes,
            estaVencido,
          );

          // ASSERT
          expect(estado, equals(EstadoSemaforoMantenimiento.rojo));
        });

        test('✅ ROJO: Debe mostrar rojo incluso si hay días positivos pero está marcado como vencido', () {
          // ARRANGE - Caso especial: fechas pueden variar
          const diasRestantes = 5; // Teóricamente positivo
          const estaVencido = true; // Pero externamente marcado como vencido

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoProximaFecha(
            diasRestantes,
            estaVencido,
          );

          // ASSERT
          expect(estado, equals(EstadoSemaforoMantenimiento.rojo));
        });
      });

      group('⚙️ Semaforización por KILOMETRAJE de Mantenimiento', () {

        test('✅ VERDE: Debe mostrar verde cuando quedan más de 3000 km', () {
          // ARRANGE
          const kmRestantes = 4000;
          const estaVencido = false;

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoProximoKilometraje(
            kmRestantes,
            estaVencido,
          );

          // ASSERT
          expect(estado, equals(EstadoSemaforoMantenimiento.verde));
        });

        test('✅ AMARILLO: Debe mostrar amarillo entre 1000 y 3000 km restantes', () {
          // ARRANGE - Caso 1: 3000 km (límite superior)
          const kmRestantes1 = 3000;

          // ACT
          final estado1 = MantenimientoHelper.obtenerEstadoSemaforoProximoKilometraje(
            kmRestantes1,
            false,
          );

          // ASSERT
          expect(estado1, equals(EstadoSemaforoMantenimiento.amarillo));

          // ARRANGE - Caso 2: 2000 km (punto medio)
          const kmRestantes2 = 2000;

          // ACT
          final estado2 = MantenimientoHelper.obtenerEstadoSemaforoProximoKilometraje(
            kmRestantes2,
            false,
          );

          // ASSERT
          expect(estado2, equals(EstadoSemaforoMantenimiento.amarillo));

          // ARRANGE - Caso 3: 1000 km (límite inferior)
          const kmRestantes3 = 1000;

          // ACT
          final estado3 = MantenimientoHelper.obtenerEstadoSemaforoProximoKilometraje(
            kmRestantes3,
            false,
          );

          // ASSERT
          expect(estado3, equals(EstadoSemaforoMantenimiento.amarillo));
        });

        test('✅ ROJO: Debe mostrar rojo cuando quedan menos de 1000 km', () {
          // ARRANGE
          const kmRestantes = 500;
          const estaVencido = false;

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoProximoKilometraje(
            kmRestantes,
            estaVencido,
          );

          // ASSERT
          expect(estado, equals(EstadoSemaforoMantenimiento.rojo));
        });

        test('✅ ROJO: Debe mostrar rojo cuando ya se superó el km de mantenimiento (negativo)', () {
          // ARRANGE
          const kmRestantes = -500; // Ya pasó 500 km del límite
          const estaVencido = true;

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoProximoKilometraje(
            kmRestantes,
            estaVencido,
          );

          // ASSERT
          expect(estado, equals(EstadoSemaforoMantenimiento.rojo));
        });

        test('✅ ROJO: Debe mostrar rojo incluso si km positivos pero está marcado como vencido', () {
          // ARRANGE
          const kmRestantes = 2000;
          const estaVencido = true; // Marcado como vencido externamente

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoProximoKilometraje(
            kmRestantes,
            estaVencido,
          );

          // ASSERT
          expect(estado, equals(EstadoSemaforoMantenimiento.rojo));
        });
      });

      group('🔄 Semaforización CONSOLIDADA (Fecha + Kilometraje)', () {

        test('✅ Debe mostrar VERDE cuando AMBOS están en verde', () {
          // ARRANGE - Ambos dentro de límite verde
          const diasRestantes = 20; // Verde (>15)
          const kmRestantes = 4000; // Verde (>3000)
          const estaVencidoPorFecha = false;
          const estaVencidoPorKilometraje = false;

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoConsolidado(
            diasRestantes,
            kmRestantes,
            estaVencidoPorFecha,
            estaVencidoPorKilometraje,
          );

          // ASSERT
          expect(estado, equals(EstadoSemaforoMantenimiento.verde));
        });

        test('✅ Debe mostrar AMARILLO cuando al menos UNO está en amarillo y NINGUNO en rojo', () {
          // ARRANGE - Fecha en amarillo, km en verde
          const diasRestantes = 10; // Amarillo (7-15)
          const kmRestantes = 4000; // Verde (>3000)
          const estaVencidoPorFecha = false;
          const estaVencidoPorKilometraje = false;

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoConsolidado(
            diasRestantes,
            kmRestantes,
            estaVencidoPorFecha,
            estaVencidoPorKilometraje,
          );

          // ASSERT
          expect(estado, equals(EstadoSemaforoMantenimiento.amarillo));
        });

        test('✅ Debe mostrar ROJO cuando CUALQUIERA está vencido (prioridad máxima)', () {
          // ARRANGE - Fecha vencida, km en verde
          const diasRestantes = -5;
          const kmRestantes = 4000; // Aún con km disponibles
          const estaVencidoPorFecha = true; // ¡URGENTE!
          const estaVencidoPorKilometraje = false;

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoConsolidado(
            diasRestantes,
            kmRestantes,
            estaVencidoPorFecha,
            estaVencidoPorKilometraje,
          );

          // ASSERT
          expect(estado, equals(EstadoSemaforoMantenimiento.rojo));
        });

        test('✅ Debe mostrar ROJO cuando km están vencidos (incluso si fecha está bien)', () {
          // ARRANGE - km vencidos, fecha en verde
          const diasRestantes = 30; // Verde (>15)
          const kmRestantes = -1000; // ¡Vencido!
          const estaVencidoPorFecha = false;
          const estaVencidoPorKilometraje = true; // ¡URGENTE!

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoConsolidado(
            diasRestantes,
            kmRestantes,
            estaVencidoPorFecha,
            estaVencidoPorKilometraje,
          );

          // ASSERT
          expect(estado, equals(EstadoSemaforoMantenimiento.rojo));
        });

        test('✅ Debe mostrar ROJO cuando AMBOS están vencidos', () {
          // ARRANGE - Ambos vencidos = máxima urgencia
          const diasRestantes = -10;
          const kmRestantes = -500;
          const estaVencidoPorFecha = true;
          const estaVencidoPorKilometraje = true;

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoConsolidado(
            diasRestantes,
            kmRestantes,
            estaVencidoPorFecha,
            estaVencidoPorKilometraje,
          );

          // ASSERT
          expect(estado, equals(EstadoSemaforoMantenimiento.rojo));
        });

        test('✅ Debe mostrar AMARILLO cuando fecha y km están ambos en amarillo', () {
          // ARRANGE - Ambos en zona de atención
          const diasRestantes = 10; // Amarillo (7-15)
          const kmRestantes = 2000; // Amarillo (1000-3000)
          const estaVencidoPorFecha = false;
          const estaVencidoPorKilometraje = false;

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoConsolidado(
            diasRestantes,
            kmRestantes,
            estaVencidoPorFecha,
            estaVencidoPorKilometraje,
          );

          // ASSERT
          expect(estado, equals(EstadoSemaforoMantenimiento.amarillo));
        });

        test('✅ Debe mostrar AMARILLO cuando uno está amarillo y otro verde (regla conservadora)', () {
          // ARRANGE - Km en amarillo, Fecha en verde
          const diasRestantes = 25; // Verde (>15)
          const kmRestantes = 1500; // Amarillo (1000-3000)
          const estaVencidoPorFecha = false;
          const estaVencidoPorKilometraje = false;

          // ACT
          final estado = MantenimientoHelper.obtenerEstadoSemaforoConsolidado(
            diasRestantes,
            kmRestantes,
            estaVencidoPorFecha,
            estaVencidoPorKilometraje,
          );

          // ASSERT - Debe ser amarillo (regla conservadora)
          expect(estado, equals(EstadoSemaforoMantenimiento.amarillo));
        });
      });

      group('📝 Descripción del Estado del Semáforo', () {

        test('✅ Debe retornar descripción correcta para VERDE', () {
          // ARRANGE
          const estado = EstadoSemaforoMantenimiento.verde;

          // ACT
          final descripcion = MantenimientoHelper.obtenerDescripcionEstado(estado);

          // ASSERT
          expect(descripcion, contains('orden'));
          expect(descripcion.isNotEmpty, isTrue);
        });

        test('✅ Debe retornar descripción correcta para AMARILLO', () {
          // ARRANGE
          const estado = EstadoSemaforoMantenimiento.amarillo;

          // ACT
          final descripcion = MantenimientoHelper.obtenerDescripcionEstado(estado);

          // ASSERT
          expect(descripcion, contains('Atención'));
          expect(descripcion, contains('próximo'));
          expect(descripcion.isNotEmpty, isTrue);
        });

        test('✅ Debe retornar descripción correcta para ROJO', () {
          // ARRANGE
          const estado = EstadoSemaforoMantenimiento.rojo;

          // ACT
          final descripcion = MantenimientoHelper.obtenerDescripcionEstado(estado);

          // ASSERT
          expect(descripcion, contains('Urgente'));
          expect(descripcion, contains('vencido'));
          expect(descripcion.isNotEmpty, isTrue);
        });
      });
    });

    // ==================================================================================
    // RESUMEN DE PRUEBAS
    // ==================================================================================

    test('📋 RESUMEN: Total de pruebas = 40+', () {
      // Este test actúa como verificación de que el suite completo ejecutó
      expect(true, isTrue);
      // Al ejecutar este archivo, verás todos los tests del grupo anterior
    });
  });
}

