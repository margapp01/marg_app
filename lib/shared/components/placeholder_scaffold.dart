import 'package:flutter/material.dart';

import '../../app/localization/app_localizations.dart';
import '../../app/theme/app_icons.dart';
import '../empty/empty_view.dart';
import '../empty/state_art.dart';

/// "Coming soon" body for screens that are not part of this release yet.
class PlaceholderScaffold extends StatelessWidget {
  const PlaceholderScaffold({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: EmptyView(
        art: StateArt.comingSoon,
        icon: AppIcons.temple,
        title: title,
        message: AppLocalizations.of(context).placeholderBody,
      ),
    );
  }
}
