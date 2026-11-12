import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:to_do_list/main.dart';

Future<void> aggiungi(WidgetTester tester, String titolo,
    {bool importante = false}) async {
  await tester.tap(find.byKey(const Key('bottoneAggiungi')));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(const Key('campoTitolo')), titolo);
  if (importante) await tester.tap(find.byKey(const Key('switchImportante')));
  await tester.tap(find.byKey(const Key('bottoneConferma')));
  await tester.pumpAndSettle();
}

String conteggio(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('conteggio'))).data!;

void main() {
  testWidgets('S2 variante: elenco vuoto mostra indicazione', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Nessuna attività'), findsOneWidget);
    expect(conteggio(tester), '0 di 0 completate');
  });

  testWidgets('S1: aggiunge attività e mostra conferma', (tester) async {
    await tester.pumpWidget(const MyApp());
    await aggiungi(tester, 'Fare la spesa', importante: true);

    expect(find.text('Fare la spesa'), findsOneWidget);
    expect(find.text('Da fare'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(conteggio(tester), '0 di 1 completate');
  });

  testWidgets('S1 variante: titolo mancante', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byKey(const Key('bottoneAggiungi')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottoneConferma')));
    await tester.pump();
    expect(find.text('Il titolo è obbligatorio'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('campoTitolo')), 'Studiare');
    await tester.pump();
    expect(find.text('Il titolo è obbligatorio'), findsNothing);
  });

  testWidgets('S1 variante: rinuncia', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.byKey(const Key('bottoneAggiungi')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('campoTitolo')), 'Bozza');
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Bozza'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Nessuna attività'), findsOneWidget);
  });

  testWidgets('S3: cambia stato e aggiorna conteggio', (tester) async {
    await tester.pumpWidget(const MyApp());
    await aggiungi(tester, 'Correre');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(find.text('Completata'), findsOneWidget);
    expect(conteggio(tester), '1 di 1 completate');

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(find.text('Da fare'), findsOneWidget);
    expect(conteggio(tester), '0 di 1 completate');
  });

  testWidgets('S4: elimina con conferma e rinuncia', (tester) async {
    await tester.pumpWidget(const MyApp());
    await aggiungi(tester, 'Leggere');

    await tester.tap(find.byTooltip('Elimina'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();
    expect(find.text('Leggere'), findsOneWidget);

    await tester.tap(find.byTooltip('Elimina'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Elimina'));
    await tester.pumpAndSettle();
    expect(find.text('Leggere'), findsNothing);
    expect(conteggio(tester), '0 di 0 completate');
  });
}
