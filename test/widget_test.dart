import 'package:flutter_test/flutter_test.dart';
import 'package:educenter/main.dart';

void main() {
  testWidgets('EduCenter app loads login screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EduCenterApp());

    // Verify login screen title is present.
    expect(find.text('O\'quv Markazi CRM'), findsOneWidget);
  });
}
