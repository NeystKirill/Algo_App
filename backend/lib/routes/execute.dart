import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Router executeRouter() {
  final router = Router();

  router.post('/execute', (Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final language = body['language'] as String;
    final code = body['code'] as String;
    final stdin = body['stdin'] as String? ?? '';

    // The public Piston API (emkc.org) went whitelist-only on 2026-02-15 and
    // rejects unregistered callers, so this talks to a self-hosted instance
    // instead. Point PISTON_URL elsewhere (or back at the public API, once
    // whitelisted) via env var.
    final pistonUrl = Platform.environment['PISTON_URL'] ?? 'http://localhost:2000/api/v2/execute';
    final pistonResponse = await http.post(
      Uri.parse(pistonUrl),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'language': language,
        'version': '*',
        'files': [
          {'content': code},
        ],
        'stdin': stdin,
      }),
    );

    return Response(
      pistonResponse.statusCode,
      body: pistonResponse.body,
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}
