import 'package:flutter_test/flutter_test.dart';
import 'package:rescue_grid/app/app.dart';

void main() {
  testWidgets('RescueGridApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RescueGridApp());
    expect(find.text('RescueGrid'), findsOneWidget);
  });
}
