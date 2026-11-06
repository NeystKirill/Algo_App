import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import '../lib/db.dart';
import '../lib/routes/algorithms.dart';
import '../lib/routes/execute.dart';

// The Flutter web app (localhost:8090 in dev) and this API (localhost:8080)
// are different origins, so the browser enforces CORS on every request —
// including a preflight OPTIONS before the actual POST /execute. Without
// these headers the browser silently blocks the response (curl doesn't
// enforce CORS, which is why the API "works" there but not in the app).
Middleware corsHeaders() {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type',
  };

  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: headers);
      }
      final response = await innerHandler(request);
      return response.change(headers: headers);
    };
  };
}

Future<void> main() async {
  final db = await openConnection();
  final router = Router()
    ..mount('/', algorithmsRouter(db))
    ..mount('/', executeRouter());
  final handler = const Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Listening on port ${server.port}');
}
