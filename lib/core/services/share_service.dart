import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/constants/app_constants.dart';
import 'analytics_service.dart';

/// What is being shared. The [wire] name is the `utm_medium` on the shared
/// link and the analytics content type, so campaigns read the same everywhere.
enum ShareKind {
  temple('temple'),
  route('route'),
  routeCompletion('route_completion'),
  certificate('certificate'),
  card('card'),
  passport('passport'),
  achievement('achievement'),
  invite('invite'),
  profile('profile'),
  blog('blog'),
  festival('festival'),
  announcement('announcement'),
  quote('quote'),
  activity('activity');

  const ShareKind(this.wire);
  final String wire;
}

/// Website paths that have a public page to land on. Anything without one is
/// shared as the sharer's invite link.
abstract final class SharePaths {
  static String temple(String slug) => '/temples/$slug';
  static String route(String slug) => '/routes/$slug';
  static String festival(String slug) => '/festivals/$slug';
  static String blog(String slug) => '/blogs/$slug';
  static String card(String cardId) => '/cards/$cardId';
  static String invite(String code) => '/invite/$code';
}

/// Builds the public URLs MARG shares: the website page, tagged with the
/// sharer's referral code and UTM parameters, or the Play Store listing.
abstract final class ShareLinks {
  static const String utmSource = 'app_share';

  /// `https://margapp.in{path}?ref=…&utm_source=app_share&utm_medium={kind}`.
  /// [path] may be relative (`/passport/abc`) or already absolute.
  static String web(String path, {required ShareKind kind, String? ref}) {
    final base = path.startsWith('http') ? Uri.parse(path) : Uri.parse('${AppConstants.webBaseUrl}$path');
    return base.replace(
      queryParameters: {
        ...base.queryParameters,
        if (ref != null && ref.isNotEmpty) 'ref': ref,
        'utm_source': utmSource,
        'utm_medium': kind.wire,
      },
    ).toString();
  }

  /// The sharer's invite landing page.
  static String invite(String code, {ShareKind kind = ShareKind.invite}) => web(SharePaths.invite(code), kind: kind);

  /// The Play Store listing, carrying the campaign through the install referrer.
  static String playStore({required ShareKind kind}) {
    final referrer = 'utm_source=$utmSource&utm_medium=${kind.wire}';
    return '${AppConstants.playStoreUrl}&referrer=${Uri.encodeQueryComponent(referrer)}';
  }
}

/// One share: the engaging text (see `ShareCopy`), what it is, and the website
/// page it lands on ([path]; null → the sharer's invite link).
class ShareMessage {
  const ShareMessage({required this.kind, required this.text, this.path, this.itemId});

  final ShareKind kind;
  final String text;
  final String? path;

  /// Identifies the shared item in analytics (slug/id); defaults to the kind.
  final String? itemId;
}

/// The signed-in user's referral code, appended to every shared link so each
/// share doubles as an invite. `core` does not know the referrals feature, so
/// the app layer overrides this (see `bootstrap.dart`); null = no code.
final shareReferralCodeProvider = FutureProvider<String?>((ref) async => null);

/// The one way MARG shares: text + link (+ an optional image or file) through
/// the system share sheet, logged to analytics.
class ShareService {
  ShareService(this._ref);

  final Ref _ref;

  static const Duration _codeTimeout = Duration(seconds: 4);

  /// The full link [message] lands on, tagged with the sharer's code.
  Future<String> linkFor(ShareMessage message) async {
    final code = await _referralCode();
    final path = message.path;
    if (path != null) return ShareLinks.web(path, kind: message.kind, ref: code);
    if (code != null) return ShareLinks.invite(code, kind: message.kind);
    return ShareLinks.playStore(kind: message.kind);
  }

  /// Opens the share sheet with [message] and its link. [capture] renders that
  /// [RepaintBoundary] to a PNG and attaches it; [file] attaches a ready file
  /// (e.g. a certificate PDF). Throws when the capture fails, so callers can
  /// show their own error.
  Future<void> share(ShareMessage message, {GlobalKey? capture, String fileName = 'marg.png', XFile? file}) async {
    final link = await linkFor(message);
    final files = [
      if (capture != null) await _capture(capture, fileName),
      ?file,
    ];
    final result = await SharePlus.instance.share(
      ShareParams(text: '${message.text}\n\n$link', files: files.isEmpty ? null : files),
    );
    if (result.status == ShareResultStatus.dismissed) return;
    await _ref.read(analyticsServiceProvider).logShare(contentType: message.kind.wire, itemId: message.itemId ?? message.kind.wire);
  }

  Future<String?> _referralCode() async {
    try {
      final code = await _ref.read(shareReferralCodeProvider.future).timeout(_codeTimeout);
      return code == null || code.isEmpty ? null : code;
    } catch (_) {
      return null;
    }
  }

  static Future<XFile> _capture(GlobalKey key, String fileName) async {
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw StateError('Nothing to capture');
    final image = await boundary.toImage(pixelRatio: 3);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) throw StateError('Capture failed');
    return XFile.fromData(bytes.buffer.asUint8List(), name: fileName, mimeType: 'image/png');
  }
}

final shareServiceProvider = Provider<ShareService>(ShareService.new);
