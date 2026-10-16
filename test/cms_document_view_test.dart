import 'package:flutter_test/flutter_test.dart';
import 'package:marg_app/shared/design_system.dart';

void main() {
  test('splits a CMS document into its opening and numbered sections', () {
    final doc = splitDocument(parseHtmlBlocks(
      '<p>Opening.</p>'
      '<h2>1. Summary</h2><p>Short.</p><ul><li>One</li></ul>'
      '<h2>२. आपके अधिकार</h2><p>Rights.</p>'
      '<h2>Contact</h2>',
    ));

    expect(doc.intro.map((b) => b.text), ['Opening.']);
    expect(doc.sections.map((s) => s.heading), ['Summary', 'आपके अधिकार', 'Contact']);
    expect(doc.sections.map((s) => s.number), ['1', '२', null]);
    expect(doc.sections.first.blocks.map((b) => b.tag), ['p', 'ul']);
    expect(doc.sections.last.blocks, isEmpty);
  });

  test('a page without section headings is all opening', () {
    final doc = splitDocument(parseHtmlBlocks('<p>About MARG.</p><p>More.</p>'));
    expect(doc.intro, hasLength(2));
    expect(doc.sections, isEmpty);
  });
}
