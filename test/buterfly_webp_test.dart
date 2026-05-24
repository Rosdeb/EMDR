import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('buterfly webp asset loads in an Image widget', (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final data = await rootBundle.load('assets/icons/buterfly.webp');
    expect(data.lengthInBytes, greaterThan(0));

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Image(image: AssetImage('assets/icons/buterfly.webp')),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });
}
