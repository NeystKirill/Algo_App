import 'dart:collection';

import '../../../core/models/graph_models.dart';
import 'demo_graph.dart';

GraphVisualization bfsDemo() {
  final graph = demoGraph();
  final adjacency = buildAdjacency(graph);
  final steps = <GraphStep>[];
  final visited = <String>[];
  final queue = Queue<String>()..add('A');
  final queued = <String>{'A'};

  steps.add(GraphStep(
    frontier: List.from(queue),
    description: 'Начинаем обход в ширину (BFS) из вершины A',
  ));

  while (queue.isNotEmpty) {
    final node = queue.removeFirst();
    visited.add(node);
    steps.add(GraphStep(
      visited: List.from(visited),
      current: node,
      frontier: List.from(queue),
      description: 'Посещаем вершину $node',
    ));

    for (final neighbor in adjacency[node]!) {
      if (!queued.contains(neighbor)) {
        queued.add(neighbor);
        queue.add(neighbor);
        steps.add(GraphStep(
          visited: List.from(visited),
          current: node,
          frontier: List.from(queue),
          description: 'Добавляем $neighbor в очередь',
        ));
      }
    }
  }

  steps.add(GraphStep(
    visited: List.from(visited),
    description: 'Обход BFS завершён',
  ));

  return GraphVisualization(definition: graph, steps: steps);
}
