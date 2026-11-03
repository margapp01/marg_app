import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/shared/content/plain_text_span.dart';

void main() {
  List<(String, bool)> runs(TextSpan span) => [
        for (final child in span.children!.cast<TextSpan>())
          (child.text!, child.style?.fontWeight == FontWeight.w600),
      ];

  test('renders **bold** runs as semi-bold', () {
    final span = plainTextSpan('On the sea wall stands the **Baan Stambh**, an arrow pillar.');
    expect(runs(span), [
      ('On the sea wall stands the ', false),
      ('Baan Stambh', true),
      (', an arrow pillar.', false),
    ]);
  });

  test('turns dash lines into bullets and collapses blank lines', () {
    final span = plainTextSpan('Built in stone:\n- sanctum\n  - shikhara\n\n\n\nDeposit them first.');
    expect(span.toPlainText(), 'Built in stone:\n•  sanctum\n•  shikhara\n\nDeposit them first.');
  });

  test('leaves text without markers alone', () {
    final span = plainTextSpan('Free entry, a * star and 2*3.');
    expect(runs(span), [('Free entry, a * star and 2*3.', false)]);
  });
}
