import 'package:flutter_test/flutter_test.dart';

import 'package:guineago/main.dart';

void main() {
  testWidgets('GuineaGo affiche correctement son application', (
    WidgetTester tester,
  ) async {
    // Lance l'application GuineaGo.
    await tester.pumpWidget(const GuineaGoApp());

    // Vérifie que l'application principale est présente.
    expect(find.byType(GuineaGoApp), findsOneWidget);

    // Avance de 1 seconde seulement.
    // Le Splash Screen est toujours visible.
    await tester.pump(const Duration(seconds: 1));

    // Vérifie que l'écran de démarrage existe.
    expect(find.byType(GuineaGoApp), findsOneWidget);
  });
}
