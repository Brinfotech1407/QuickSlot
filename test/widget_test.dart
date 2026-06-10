import 'package:boilerplate/app.dart';
import 'package:boilerplate/core/di/service_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await setupServiceLocator();
  });

  testWidgets('shows splash then home sample data',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Flutter Boilerplate'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Clean Architecture'), findsOneWidget);
    expect(find.text('Bloc/Cubit Ready'), findsOneWidget);
    expect(find.text('API Layer'), findsOneWidget);
  });
}
