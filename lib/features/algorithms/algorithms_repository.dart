import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_config.dart';
import '../../core/models/algorithm_info.dart';
import 'registry.dart';

Future<List<AlgorithmInfo>> fetchAlgorithms() async {
  try {
    final response = await http
        .get(Uri.parse('$apiBaseUrl/algorithms'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) return algorithmRegistry;

    final rows = jsonDecode(response.body) as List;
    return rows.map((row) {
      final id = row['id'] as String;
      final local = algorithmRegistry.firstWhere((a) => a.id == id);
      final codeSamples = (row['code_samples'] as List)
          .map((s) => CodeSample(language: s['language'] as String, code: s['code'] as String))
          .toList();

      return AlgorithmInfo(
        id: id,
        title: row['title'] as String,
        category: AlgoCategory.values.byName(row['category'] as String),
        difficulty: Difficulty.values.byName(row['difficulty'] as String),
        theory: row['theory'] as String,
        timeComplexity: row['time_complexity'] as String,
        spaceComplexity: row['space_complexity'] as String,
        visualizationKind: VisualizationKind.values.byName(row['visualization_kind'] as String),
        codeSamples: codeSamples,
        buildArraySteps: local.buildArraySteps,
        buildGraphVisualization: local.buildGraphVisualization,
      );
    }).toList();
  } catch (_) {
    return algorithmRegistry;
  }
}
