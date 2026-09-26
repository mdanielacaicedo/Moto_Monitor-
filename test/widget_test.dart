// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:moto_monitor/main.dart';
import 'package:moto_monitor/providers/app_provider.dart';

void main() {
  // 🚀 Prueba básica de widget: Verifica que la app MotoMonitorApp se construye sin errores
  testWidgets('MotoMonitorApp builds without errors', (WidgetTester tester) async {
    // 📱 Construye la app con Provider
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AppProvider(),
        child: const MotoMonitorApp(),
      ),
    );

    // ⏳ Espera un frame para que se renderice
    await tester.pump();

    // ✅ Verifica que el widget se construyó correctamente
    expect(find.byType(MotoMonitorApp), findsOneWidget);

    // ✅ Verifica que no hay excepciones sin capturar
    expect(tester.takeException(), isNull);
  });
}
