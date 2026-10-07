import 'dart:io';

import 'package:postgres/postgres.dart';

Future<Connection> openConnection() {
  final env = Platform.environment;
  return Connection.open(
    Endpoint(
      host: env['SUPABASE_DB_HOST']!,
      port: int.parse(env['SUPABASE_DB_PORT'] ?? '5432'),
      database: env['SUPABASE_DB_NAME'] ?? 'postgres',
      username: env['SUPABASE_DB_USER'] ?? 'postgres',
      password: env['SUPABASE_DB_PASSWORD']!,
    ),
    settings: const ConnectionSettings(sslMode: SslMode.require),
  );
}
