import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DriverInspectorApp());
    expect(find.byType(DriverInspectorApp), findsOneWidget);
  });
}
