import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

import '../lib/db.dart';
import '../lib/routes/algorithms.dart';
import '../lib/routes/execute.dart';

Future<void> main() async {
  final db = await openConnection();
  final router = Router()
    ..mount('/', algorithmsRouter(db))
    ..mount('/', executeRouter());
  final handler = const Pipeline().addMiddleware(logRequests()).addHandler(router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('Listening on port ${server.port}');
}
