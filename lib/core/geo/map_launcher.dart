import 'package:url_launcher/url_launcher.dart';

/// Opens the device's default maps app with turn-by-turn directions to the
/// given coordinates. Returns false if no maps app could be launched.
Future<bool> openExternalDirections({required double latitude, required double longitude}) async {
  final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude');
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
