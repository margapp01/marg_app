import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../../shared/components/placeholder_scaffold.dart';

/// Placeholder — Temple discovery arrives in its feature phase.
class TemplesPage extends StatelessWidget {
  const TemplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(title: AppLocalizations.of(context).titleTemples);
  }
}
