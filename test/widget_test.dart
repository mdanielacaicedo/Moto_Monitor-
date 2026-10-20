import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:moto_monitor/main.dart';
import 'package:moto_monitor/providers/app_provider.dart';

void main() {
  testWidgets('MotoMonitorApp builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AppProvider(),
        child: const MotoMonitorApp(),
      ),
    );

    await tester.pump();

    expect(find.byType(MotoMonitorApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
