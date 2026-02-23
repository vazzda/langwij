import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:srpski_card/main.dart';
import 'package:srpski_card/app/router/app_router.dart';

void main() {
  testWidgets('App starts and shows group list', (WidgetTester tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(
      ProviderScope(
        child: SrpskiCardApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Srpski Card'), findsOneWidget);
  });
}
