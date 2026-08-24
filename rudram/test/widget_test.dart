import 'package:flutter_test/flutter_test.dart';
import 'package:rudram/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our static text is present.
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Flash Sales'), findsOneWidget);
  });
}
