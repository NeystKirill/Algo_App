import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Renders a Cloudflare Turnstile challenge inside a WebView and reports the
/// verification token back via [onToken] once the visitor passes it.
///
/// Turnstile tokens are single-use: give this widget a new [key] (e.g. bump
/// a counter) to force a fresh challenge after a failed sign-in/sign-up
/// attempt, since the previous token is no longer valid.
class TurnstileWidget extends StatefulWidget {
  const TurnstileWidget({super.key, required this.siteKey, required this.onToken});

  final String siteKey;
  final ValueChanged<String> onToken;

  @override
  State<TurnstileWidget> createState() => _TurnstileWidgetState();
}

class _TurnstileWidgetState extends State<TurnstileWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'TurnstileChannel',
        onMessageReceived: (message) => widget.onToken(message.message),
      )
      ..loadHtmlString(_html(widget.siteKey));
  }

  static String _html(String siteKey) => '''
<!DOCTYPE html>
<html>
  <head>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
    <style>
      html, body { margin: 0; padding: 0; background: transparent; }
      body { display: flex; justify-content: center; align-items: center; }
    </style>
  </head>
  <body>
    <div class="cf-turnstile" data-sitekey="$siteKey" data-callback="onTurnstileSuccess"></div>
    <script>
      function onTurnstileSuccess(token) {
        TurnstileChannel.postMessage(token);
      }
    </script>
  </body>
</html>
''';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: WebViewWidget(controller: _controller),
    );
  }
}
