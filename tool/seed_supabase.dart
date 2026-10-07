import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';

import 'package:algo_learning_app/features/algorithms/registry.dart';

Future<void> main() async {
  final env = Platform.environment;
  final connection = await Connection.open(
    Endpoint(
      host: env['SUPABASE_DB_HOST']!,
      port: int.parse(env['SUPABASE_DB_PORT'] ?? '5432'),
      database: env['SUPABASE_DB_NAME'] ?? 'postgres',
      username: env['SUPABASE_DB_USER'] ?? 'postgres',
      password: env['SUPABASE_DB_PASSWORD']!,
    ),
    settings: const ConnectionSettings(sslMode: SslMode.require),
  );

  for (final algorithm in algorithmRegistry) {
    final codeSamples = algorithm.codeSamples
        .map((sample) => {'language': sample.language, 'code': sample.code})
        .toList();

    await connection.execute(
      Sql.named('''
        insert into algorithms (id, title, category, difficulty, theory, time_complexity, space_complexity, visualization_kind, code_samples)
        values (@id, @title, @category, @difficulty, @theory, @timeComplexity, @spaceComplexity, @visualizationKind, @codeSamples)
        on conflict (id) do update set
          title = excluded.title,
          category = excluded.category,
          difficulty = excluded.difficulty,
          theory = excluded.theory,
          time_complexity = excluded.time_complexity,
          space_complexity = excluded.space_complexity,
          visualization_kind = excluded.visualization_kind,
          code_samples = excluded.code_samples
      '''),
      parameters: {
        'id': algorithm.id,
        'title': algorithm.title,
        'category': algorithm.category.name,
        'difficulty': algorithm.difficulty.name,
        'theory': algorithm.theory,
        'timeComplexity': algorithm.timeComplexity,
        'spaceComplexity': algorithm.spaceComplexity,
        'visualizationKind': algorithm.visualizationKind.name,
        'codeSamples': jsonEncode(codeSamples),
      },
    );
    print('seeded ${algorithm.id}');
  }

  await connection.close();
}
