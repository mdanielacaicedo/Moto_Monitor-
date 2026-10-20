import 'package:flutter_test/flutter_test.dart';
import 'package:moto_monitor/utils/mantenimiento_helper.dart';

void main() {
  group('Pruebas de mantenimiento', () {
    group('estimación', () {
      test('calcula días restantes', () {
        final ultimaFecha = DateTime.now().subtract(const Duration(days: 30));
        final proximaFecha = DateTime.now().add(const Duration(days: 20));

        final diasRestantes = MantenimientoHelper.calcularDiasRestantes(
          ultimaFecha,
          proximaFecha,
        );

        expect(diasRestantes, greaterThanOrEqualTo(19));
        expect(diasRestantes, lessThanOrEqualTo(21));
      });

      test('detecta mantenimiento vencido', () {
        final ultimaFecha = DateTime.now().subtract(const Duration(days: 60));
        final proximaFecha = DateTime.now().subtract(const Duration(days: 10));

        final diasRestantes = MantenimientoHelper.calcularDiasRestantes(
          ultimaFecha,
          proximaFecha,
        );

        expect(diasRestantes, lessThan(0));
      });

      test('calcula kilometraje restante', () {
        const kilometrajeActual = 15000;
        const ultimoKilometraje = 10000;
        const intervaloRecomendado = 5000;

        final kmRestantes = MantenimientoHelper.calcularKilometrajeRestante(
          kilometrajeActual,
          ultimoKilometraje,
          intervaloRecomendado,
        );

        expect(kmRestantes, equals(0));
      });

      test('cuando falta kilometraje', () {
        const kilometrajeActual = 12000;
        const ultimoKilometraje = 10000;
        const intervaloRecomendado = 5000;

        final kmRestantes = MantenimientoHelper.calcularKilometrajeRestante(
          kilometrajeActual,
          ultimoKilometraje,
          intervaloRecomendado,
        );

        expect(kmRestantes, equals(3000));
      });

      test('detecta kilometraje vencido', () {
        const kilometrajeActual = 16000;
        const ultimoKilometraje = 10000;
        const intervaloRecomendado = 5000;

        final kmRestantes = MantenimientoHelper.calcularKilometrajeRestante(
          kilometrajeActual,
          ultimoKilometraje,
          intervaloRecomendado,
        );

        expect(kmRestantes, lessThan(0));
        expect(kmRestantes, equals(-1000));
      });

      test('estima próxima fecha por km promedio', () {
        final hoaAxiom = DateTime.now();
        const kilometrajeActual = 10000;
        const ultimoKilometraje = 9000;
        const intervaloRecomendado = 5000;
        const kmDiarios = 100;

        final proximaFecha = MantenimientoHelper.estimarProximaFechaMantenimiento(
          hoaAxiom,
          kilometrajeActual,
          ultimoKilometraje,
          intervaloRecomendado,
          kmDiarios,
        );

        final diasEstimados = proximaFecha.difference(DateTime.now()).inDays;
        expect(diasEstimados, greaterThanOrEqualTo(39));
        expect(diasEstimados, lessThanOrEqualTo(41));
      });
    });

    group('kilometraje', () {
      test('acepta aumento válido', () {
        const ultimoKilometraje = 10000;
        const nuevoKilometraje = 10500;

        final esValido = MantenimientoHelper.validarKilometraje(
          nuevoKilometraje,
          ultimoKilometraje,
        );

        expect(esValido, isTrue);
      });

      test('permite igualdad', () {
        const ultimoKilometraje = 10000;
        const nuevoKilometraje = 10000;

        final esValido = MantenimientoHelper.validarKilometraje(
          nuevoKilometraje,
          ultimoKilometraje,
        );

        expect(esValido, isTrue);
      });

      test('rechaza retroceso', () {
        const ultimoKilometraje = 10000;
        const nuevoKilometraje = 9500;

        final esValido = MantenimientoHelper.validarKilometraje(
          nuevoKilometraje,
          ultimoKilometraje,
        );

        expect(esValido, isFalse);
      });

      test('rechaza retroceso grande', () {
        const ultimoKilometraje = 150000;
        const nuevoKilometraje = 100000;

        final esValido = MantenimientoHelper.validarKilometraje(
          nuevoKilometraje,
          ultimoKilometraje,
        );

        expect(esValido, isFalse);
      });

      test('acepta incremento pequeño', () {
        const ultimoKilometraje = 95000;
        const nuevoKilometraje = 95050;

        final esValido = MantenimientoHelper.validarKilometraje(
          nuevoKilometraje,
          ultimoKilometraje,
        );

        expect(esValido, isTrue);
      });

      test('acepta incremento grande', () {
        const ultimoKilometraje = 50000;
        const nuevoKilometraje = 51500;

        final esValido = MantenimientoHelper.validarKilometraje(
          nuevoKilometraje,
          ultimoKilometraje,
        );

        expect(esValido, isTrue);
      });
    });
  });
}
