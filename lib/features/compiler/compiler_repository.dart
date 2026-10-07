import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_config.dart';

class ExecutionResult {
  final String stdout;
  final String stderr;
  final int exitCode;

  const ExecutionResult({required this.stdout, required this.stderr, required this.exitCode});
}

Future<ExecutionResult> runCode({
  required String language,
  required String code,
  String stdin = '',
}) async {
  final response = await http.post(
    Uri.parse('$apiBaseUrl/execute'),
    headers: {'content-type': 'application/json'},
    body: jsonEncode({'language': language, 'code': code, 'stdin': stdin}),
  );

  if (response.statusCode != 200) {
    throw Exception('Execution failed: ${response.statusCode} ${response.body}');
  }

  final json = jsonDecode(response.body) as Map<String, dynamic>;
  final run = json['run'] as Map<String, dynamic>;

  return ExecutionResult(
    stdout: run['stdout'] as String? ?? '',
    stderr: run['stderr'] as String? ?? '',
    exitCode: run['code'] as int? ?? 0,
  );
}
