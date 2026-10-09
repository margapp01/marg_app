import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../../shared/components/placeholder_scaffold.dart';

/// Placeholder — full temple detail arrives in the temples phase.
/// Already deep-link addressable via /temples/:templeId.
class TempleDetailPage extends StatelessWidget {
  const TempleDetailPage({required this.templeId, super.key});

  final String templeId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PlaceholderScaffold(title: '${l10n.titleTempleDetail} · $templeId');
  }
}
