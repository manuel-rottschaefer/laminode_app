class GraphEdge {
  final String sourceId;
  final String targetId;

  const GraphEdge(this.sourceId, this.targetId);

  String get id => '$sourceId|$targetId';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphEdge &&
          runtimeType == other.runtimeType &&
          sourceId == other.sourceId &&
          targetId == other.targetId;

  @override
  int get hashCode => sourceId.hashCode ^ targetId.hashCode;
}
