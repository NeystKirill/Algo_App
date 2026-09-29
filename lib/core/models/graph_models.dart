class GraphPoint {
  final double x;
  final double y;

  const GraphPoint(this.x, this.y);
}

class GraphNodeData {
  final String id;
  final GraphPoint position;

  const GraphNodeData({required this.id, required this.position});
}

class GraphEdgeData {
  final String from;
  final String to;

  const GraphEdgeData({required this.from, required this.to});
}

class GraphDefinition {
  final List<GraphNodeData> nodes;
  final List<GraphEdgeData> edges;

  const GraphDefinition({required this.nodes, required this.edges});
}

class GraphStep {
  final List<String> visited;
  final String? current;
  final List<String> frontier;
  final String description;

  const GraphStep({
    this.visited = const [],
    this.current,
    this.frontier = const [],
    required this.description,
  });
}

class GraphVisualization {
  final GraphDefinition definition;
  final List<GraphStep> steps;

  const GraphVisualization({required this.definition, required this.steps});
}
