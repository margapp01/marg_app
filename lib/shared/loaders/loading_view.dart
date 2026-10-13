import 'package:flutter/material.dart';

import 'brand_loader.dart';

/// Full-area loading state: the MARG [BrandLoader] with an optional caption.
class LoadingView extends StatelessWidget {
  const LoadingView({this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) => Center(child: BrandLoader(message: message));
}
