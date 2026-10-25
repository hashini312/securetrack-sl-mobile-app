import 'package:flutter_test/flutter_test.dart';
import 'package:owner_inspector_app/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OwnerApp());
    expect(find.byType(OwnerApp), findsOneWidget);
  });
}
