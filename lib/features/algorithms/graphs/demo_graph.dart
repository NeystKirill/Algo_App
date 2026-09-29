import '../../../core/models/graph_models.dart';

GraphDefinition demoGraph() {
  const nodes = [
    GraphNodeData(id: 'A', position: GraphPoint(0.5, 0.1)),
    GraphNodeData(id: 'B', position: GraphPoint(0.2, 0.4)),
    GraphNodeData(id: 'C', position: GraphPoint(0.8, 0.4)),
    GraphNodeData(id: 'D', position: GraphPoint(0.1, 0.75)),
    GraphNodeData(id: 'E', position: GraphPoint(0.5, 0.75)),
    GraphNodeData(id: 'F', position: GraphPoint(0.85, 0.75)),
  ];
  const edges = [
    GraphEdgeData(from: 'A', to: 'B'),
    GraphEdgeData(from: 'A', to: 'C'),
    GraphEdgeData(from: 'B', to: 'D'),
    GraphEdgeData(from: 'B', to: 'E'),
    GraphEdgeData(from: 'C', to: 'E'),
    GraphEdgeData(from: 'C', to: 'F'),
  ];
  return const GraphDefinition(nodes: nodes, edges: edges);
}

Map<String, List<String>> buildAdjacency(GraphDefinition graph) {
  final map = <String, List<String>>{
    for (final node in graph.nodes) node.id: <String>[],
  };
  for (final edge in graph.edges) {
    map[edge.from]!.add(edge.to);
    map[edge.to]!.add(edge.from);
  }
  for (final neighbors in map.values) {
    neighbors.sort();
  }
  return map;
}
