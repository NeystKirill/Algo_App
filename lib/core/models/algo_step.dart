class AlgoStep {
  final List<int> array;
  final List<int> compared;
  final List<int> swapped;
  final List<int> sorted;
  final List<int> markers;
  final String description;
  final int comparisons;
  final int swaps;

  const AlgoStep({
    required this.array,
    this.compared = const [],
    this.swapped = const [],
    this.sorted = const [],
    this.markers = const [],
    required this.description,
    this.comparisons = 0,
    this.swaps = 0,
  });
}
