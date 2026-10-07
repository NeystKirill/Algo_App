import 'dart:convert';

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

    final pistonResponse = await http.post(
      Uri.parse('https://emkc.org/api/v2/piston/execute'),
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
