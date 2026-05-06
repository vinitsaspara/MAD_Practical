import 'package:flutter_test/flutter_test.dart';
import 'package:mad/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PeerTutoringApp());
    expect(find.byType(PeerTutoringApp), findsOneWidget);
  });
}
