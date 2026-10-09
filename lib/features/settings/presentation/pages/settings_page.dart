import 'package:flutter/material.dart';

import '../../../../app/localization/app_localizations.dart';
import '../../../../shared/components/placeholder_scaffold.dart';

/// Placeholder — Settings arrives in its feature phase.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderScaffold(title: AppLocalizations.of(context).titleSettings);
  }
}
