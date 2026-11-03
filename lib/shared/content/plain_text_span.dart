import 'package:flutter/painting.dart';

import '../../core/extensions/context_extensions.dart';

final _bold = RegExp(r'\*\*(.+?)\*\*');
final _bullet = RegExp(r'^[-*•]\s+');
final _extraBlankLines = RegExp(r'\n{3,}');

/// Admin-typed plain text as spans for `Text.rich`: `**bold**` runs become
/// semi-bold, `- ` lines become `•` bullets, and runs of blank lines collapse
/// to one. Staying a single span keeps `maxLines` / ellipsis truncation working.
TextSpan plainTextSpan(String text, {TextStyle? style}) {
  final body = text
      .trim()
      .split('\n')
      .map((line) => line.trim().replaceFirst(_bullet, '•  '))
      .join('\n')
      .replaceAll(_extraBlankLines, '\n\n');
  final bold = (style ?? const TextStyle()).semiBold;
  final children = <TextSpan>[];
  var start = 0;
  for (final match in _bold.allMatches(body)) {
    if (match.start > start) children.add(TextSpan(text: body.substring(start, match.start)));
    children.add(TextSpan(text: match.group(1), style: bold));
    start = match.end;
  }
  if (start < body.length) children.add(TextSpan(text: body.substring(start)));
  return TextSpan(style: style, children: children);
}
