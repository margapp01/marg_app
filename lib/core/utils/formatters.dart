/// Small, locale-neutral display formatters shared across features.
library;

/// `980` → "980", `2345` → "2.3K", `12500` → "12.5K", `1_200_000` → "1.2M".
String compactCount(int value) {
  if (value < 1000) return '$value';
  if (value < 1000000) return '${_trim(value / 1000)}K';
  return '${_trim(value / 1000000)}M';
}

String _trim(double v) {
  final fixed = v.toStringAsFixed(v >= 100 ? 0 : 1);
  return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
}

/// "21:00" → "9 PM", "05:30" → "5:30 AM". Returns the input when unparsable.
String formatClock(String hhmm) {
  final parts = hhmm.split(':');
  final h = int.tryParse(parts.first);
  final m = parts.length > 1 ? int.tryParse(parts[1]) : 0;
  if (h == null || m == null) return hhmm;
  return formatHour(h, minute: m);
}

/// `6` → "6 AM", `18` → "6 PM", `0` → "12 AM" (optional minutes).
String formatHour(int hour, {int minute = 0}) {
  final h = hour % 24;
  final suffix = h < 12 ? 'AM' : 'PM';
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return minute == 0 ? '$h12 $suffix' : '$h12:${minute.toString().padLeft(2, '0')} $suffix';
}

/// A one-hour slot starting at [hour]: `6` → "6 AM – 7 AM".
String formatHourSlot(int hour) => '${formatHour(hour)} – ${formatHour(hour + 1)}';

/// "850 m" under a kilometre, "12.4 km" beyond; "—" when unknown.
String formatDistance(double? meters) {
  if (meters == null) return '—';
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}
