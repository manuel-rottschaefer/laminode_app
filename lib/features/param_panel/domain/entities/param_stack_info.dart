class ParamLayerContribution {
  final String layerName;
  final String valueDisplay;
  final String? layerCategory;
  final bool isBase;
  final bool isOverride;
  final bool isConstraint;

  const ParamLayerContribution({
    required this.layerName,
    required this.valueDisplay,
    this.layerCategory,
    this.isBase = false,
    this.isOverride = false,
    this.isConstraint = false,
  });
}

class ParamStackInfo {
  final String paramName;
  final List<ParamLayerContribution> contributions;

  const ParamStackInfo({required this.paramName, required this.contributions});
}
