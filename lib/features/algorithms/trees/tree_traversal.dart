import '../../../core/models/graph_models.dart';
import 'demo_tree.dart';

GraphVisualization _traversalVisualization(void Function(void Function(String) visit) run) {
  final graph = demoTreeGraph();
  final steps = <GraphStep>[];
  final visited = <String>[];

  void visit(String nodeId) {
    visited.add(nodeId);
    steps.add(GraphStep(
      visited: List.from(visited),
      current: nodeId,
      description: 'Посещаем узел $nodeId',
    ));
  }

  steps.add(const GraphStep(description: 'Начинаем обход дерева'));
  run(visit);
  steps.add(GraphStep(visited: List.from(visited), description: 'Обход завершён'));

  return GraphVisualization(definition: graph, steps: steps);
}

void _preOrder(String? nodeId, void Function(String) visit) {
  if (nodeId == null) return;
  final node = demoTreeNodes[nodeId]!;
  visit(nodeId);
  _preOrder(node.left, visit);
  _preOrder(node.right, visit);
}

void _inOrder(String? nodeId, void Function(String) visit) {
  if (nodeId == null) return;
  final node = demoTreeNodes[nodeId]!;
  _inOrder(node.left, visit);
  visit(nodeId);
  _inOrder(node.right, visit);
}

void _postOrder(String? nodeId, void Function(String) visit) {
  if (nodeId == null) return;
  final node = demoTreeNodes[nodeId]!;
  _postOrder(node.left, visit);
  _postOrder(node.right, visit);
  visit(nodeId);
}

GraphVisualization preOrderDemo() =>
    _traversalVisualization((visit) => _preOrder(demoTreeRoot, visit));

GraphVisualization inOrderDemo() =>
    _traversalVisualization((visit) => _inOrder(demoTreeRoot, visit));

GraphVisualization postOrderDemo() =>
    _traversalVisualization((visit) => _postOrder(demoTreeRoot, visit));
