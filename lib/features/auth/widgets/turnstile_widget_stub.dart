import 'package:flutter/material.dart';

/// Placeholder used only if Flutter targets a platform that is neither
/// `dart.library.js_interop` (web) nor `dart.library.io` (Android, iOS,
/// desktop) — i.e. never, for any real Flutter build target.
class TurnstileWidget extends StatelessWidget {
  const TurnstileWidget({super.key, required this.siteKey, required this.onToken});

  final String siteKey;
  final ValueChanged<String> onToken;

  @override
  Widget build(BuildContext context) =>
      throw UnsupportedError('Turnstile is not supported on this platform.');
}
