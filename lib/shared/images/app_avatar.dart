import 'package:flutter/material.dart';

import '../../app/theme/app_icons.dart';
import '../../core/extensions/context_extensions.dart';
import '../components/app_network_image.dart';

/// Circular user/temple avatar. Shows a cached network image when [imageUrl]
/// is set, otherwise initials derived from [name], otherwise a person glyph.
/// One avatar implementation for the whole app.
class AppAvatar extends StatelessWidget {
  const AppAvatar({this.imageUrl, this.name, this.radius = 20, this.backgroundColor, super.key});

  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;

  String get _initials {
    final parts = (name ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? context.scheme.primaryContainer;
    final diameter = radius * 2;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: AppNetworkImage(url: imageUrl!, width: diameter, height: diameter),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: _initials.isEmpty
          ? Icon(AppIcons.profile, size: radius, color: context.scheme.onPrimaryContainer)
          : Text(
              _initials,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.scheme.onPrimaryContainer,
                fontSize: radius * 0.8,
              ),
            ),
    );
  }
}
