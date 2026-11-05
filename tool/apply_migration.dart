import 'dart:io';

import 'package:postgres/postgres.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run tool/apply_migration.dart <path-to-sql-file>');
    exit(1);
  }

  final sql = await File(args.first).readAsString();
  final env = Platform.environment;

  final connection = await Connection.open(
    Endpoint(
      host: env['SUPABASE_DB_HOST']!,
      port: int.parse(env['SUPABASE_DB_PORT'] ?? '5432'),
      database: env['SUPABASE_DB_NAME'] ?? 'postgres',
      username: env['SUPABASE_DB_USER'] ?? 'postgres',
      password: env['SUPABASE_DB_PASSWORD']!,
    ),
    // Local `supabase start` Postgres doesn't terminate TLS; set
    // SUPABASE_DB_SSL=disable for it, leave unset (require) for hosted.
    settings: ConnectionSettings(
      sslMode: env['SUPABASE_DB_SSL'] == 'disable' ? SslMode.disable : SslMode.require,
    ),
  );

  await connection.execute(sql);
  print('Migration applied: ${args.first}');
  await connection.close();
}
