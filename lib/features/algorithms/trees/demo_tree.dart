import '../../../core/models/graph_models.dart';

class TreeNode {
  final String id;
  final String? left;
  final String? right;

  const TreeNode({required this.id, this.left, this.right});
}

const Map<String, TreeNode> demoTreeNodes = {
  '8': TreeNode(id: '8', left: '3', right: '10'),
  '3': TreeNode(id: '3', left: '1', right: '6'),
  '10': TreeNode(id: '10', right: '14'),
  '1': TreeNode(id: '1'),
  '6': TreeNode(id: '6'),
  '14': TreeNode(id: '14'),
};

const demoTreeRoot = '8';

GraphDefinition demoTreeGraph() {
  const positions = {
    '8': GraphPoint(0.5, 0.12),
    '3': GraphPoint(0.28, 0.45),
    '10': GraphPoint(0.72, 0.45),
    '1': GraphPoint(0.15, 0.78),
    '6': GraphPoint(0.4, 0.78),
    '14': GraphPoint(0.85, 0.78),
  };

  final nodes = [
    for (final entry in positions.entries) GraphNodeData(id: entry.key, position: entry.value),
  ];

  final edges = <GraphEdgeData>[];
  for (final node in demoTreeNodes.values) {
    if (node.left != null) edges.add(GraphEdgeData(from: node.id, to: node.left!));
    if (node.right != null) edges.add(GraphEdgeData(from: node.id, to: node.right!));
  }

  return GraphDefinition(nodes: nodes, edges: edges);
}
