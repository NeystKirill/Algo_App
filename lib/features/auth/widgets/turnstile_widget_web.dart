import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Flutter Web implementation of the Turnstile widget.
///
/// `webview_flutter` (used on Android/iOS/desktop, see `turnstile_widget_io`)
/// has no web backend at all, so on web this instead injects Cloudflare's
/// `api.js` into the page once and renders the challenge straight into the
/// DOM through a platform view, with the result reported back via a Dart
/// callback (no postMessage/JS channel needed since there's no iframe
/// boundary to cross).
class TurnstileWidget extends StatefulWidget {
  const TurnstileWidget({super.key, required this.siteKey, required this.onToken});

  final String siteKey;
  final ValueChanged<String> onToken;

  @override
  State<TurnstileWidget> createState() => _TurnstileWidgetState();
}

int _viewCounter = 0;
Completer<void>? _scriptLoad;

Future<void> _ensureTurnstileScript() {
  final existing = _scriptLoad;
  if (existing != null) return existing.future;

  final completer = Completer<void>();
  _scriptLoad = completer;

  if (globalContext.has('turnstile')) {
    completer.complete();
    return completer.future;
  }

  final script = web.HTMLScriptElement()
    ..src = 'https://challenges.cloudflare.com/turnstile/v0/api.js'
    ..async = true
    ..defer = true;
  script.addEventListener('load', ((web.Event _) => completer.complete()).toJS);
  script.addEventListener(
    'error',
    ((web.Event _) =>
        completer.completeError(StateError('Failed to load the Turnstile script'))).toJS,
  );
  web.document.head!.append(script);

  return completer.future;
}

@JS('turnstile.render')
external JSAny? _turnstileRender(web.Element container, JSObject options);

class _TurnstileWidgetState extends State<TurnstileWidget> {
  late final String _viewId = 'turnstile-${_viewCounter++}';
  late final web.HTMLDivElement _container = web.HTMLDivElement()
    ..id = _viewId
    ..style.display = 'flex'
    ..style.justifyContent = 'center';
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int _) => _container);
    _ensureTurnstileScript().then((_) {
      if (_disposed) return;
      final options = JSObject()
        ..setProperty('sitekey'.toJS, widget.siteKey.toJS)
        ..setProperty(
          'callback'.toJS,
          ((JSString token) => widget.onToken(token.toDart)).toJS,
        );
      _turnstileRender(_container, options);
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
