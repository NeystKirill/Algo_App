import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

Router algorithmsRouter(Connection db) {
  final router = Router();

  router.get('/algorithms', (Request request) async {
    final result = await db.execute('select * from algorithms order by id');
    final rows = result.map((row) => row.toColumnMap()).toList();
    return Response.ok(jsonEncode(rows), headers: _jsonHeaders);
  });

  router.get('/algorithms/<id>', (Request request, String id) async {
    final result = await db.execute(
      Sql.named('select * from algorithms where id = @id'),
      parameters: {'id': id},
    );
    if (result.isEmpty) {
      return Response.notFound(jsonEncode({'error': 'not found'}), headers: _jsonHeaders);
    }
    return Response.ok(jsonEncode(result.first.toColumnMap()), headers: _jsonHeaders);
  });

  return router;
}

const _jsonHeaders = {'content-type': 'application/json'};
