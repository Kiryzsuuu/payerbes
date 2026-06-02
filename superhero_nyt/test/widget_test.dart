import 'package:flutter_test/flutter_test.dart';
import 'package:superhero_nyt/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HeroTimesApp());
    expect(find.byType(HeroTimesApp), findsOneWidget);
  });
}
