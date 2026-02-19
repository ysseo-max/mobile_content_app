import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_content/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MobileContentApp());
    await tester.pumpAndSettle();

    // Verify the home screen is displayed
    expect(find.text('AI & Stamp Mobile Content'), findsAny);
  });
}
