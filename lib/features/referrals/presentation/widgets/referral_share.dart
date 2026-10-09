import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// A named social/share target for the Invite Friends screen.
enum ShareTarget { whatsapp, telegram, twitter, email, facebook, system }

/// Opens a share target with the invite [text]. WhatsApp / Telegram / X / Email
/// use reliable web-intent URLs; Facebook + "More" fall back to the system share
/// sheet (share_plus) — no fabricated deep links.
Future<void> shareReferral(ShareTarget target, {required String text, required String link}) async {
  switch (target) {
    case ShareTarget.whatsapp:
      await _launch(Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}'));
    case ShareTarget.telegram:
      await _launch(Uri.parse('https://t.me/share/url?url=${Uri.encodeComponent(link)}&text=${Uri.encodeComponent(text)}'));
    case ShareTarget.twitter:
      await _launch(Uri.parse('https://twitter.com/intent/tweet?text=${Uri.encodeComponent(text)}'));
    case ShareTarget.email:
      await _launch(Uri(scheme: 'mailto', queryParameters: {'subject': 'Join me on MARG', 'body': text}));
    case ShareTarget.facebook:
    case ShareTarget.system:
      await SharePlus.instance.share(ShareParams(text: text));
  }
}

Future<void> _launch(Uri uri) async {
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {/* best-effort */}
}
