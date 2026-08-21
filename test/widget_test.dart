import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flapverse_3d/main.dart';

void main() {
  testWidgets('Flapverse home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FlapverseApp()));
    await tester.pump();

    expect(find.text('PLAY'), findsOneWidget);
  });
}
