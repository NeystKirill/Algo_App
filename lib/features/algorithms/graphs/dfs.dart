import '../../../core/models/graph_models.dart';
import 'demo_graph.dart';

GraphVisualization dfsDemo() {
  final graph = demoGraph();
  final adjacency = buildAdjacency(graph);
  final steps = <GraphStep>[];
  final visited = <String>[];

  void visit(String node) {
    visited.add(node);
    steps.add(GraphStep(
      visited: List.from(visited),
      current: node,
      description: 'Посещаем вершину $node',
    ));

    for (final neighbor in adjacency[node]!) {
      if (!visited.contains(neighbor)) {
        steps.add(GraphStep(
          visited: List.from(visited),
          current: node,
          frontier: [neighbor],
          description: 'Идём вглубь к вершине $neighbor',
        ));
        visit(neighbor);
      }
    }
  }

  steps.add(const GraphStep(description: 'Начинаем обход в глубину (DFS) из вершины A'));
  visit('A');
  steps.add(GraphStep(visited: List.from(visited), description: 'Обход DFS завершён'));

  return GraphVisualization(definition: graph, steps: steps);
}
