import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:langwij/main.dart';
import 'package:langwij/app/router/app_router.dart';

void main() {
  testWidgets('App starts and shows group list', (WidgetTester tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(
      ProviderScope(
        child: LangwijApp(router: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Langwij'), findsOneWidget);
  });
}
