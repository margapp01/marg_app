import 'package:flutter/material.dart';

import '../../../../../app/localization/app_localizations.dart';
import '../../../../../shared/components/placeholder_scaffold.dart';

/// Placeholder — Visit history + check-in arrives in its feature phase.
class VisitsPage extends StatelessWidget {
  const VisitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(title: AppLocalizations.of(context).titleVisits);
  }
}
