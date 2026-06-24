import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('Carga la app correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const DeliveryApp());

    expect(find.text('Delivery App'), findsOneWidget);
  });
}