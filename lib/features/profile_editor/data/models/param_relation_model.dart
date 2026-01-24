import 'package:laminode_app/core/domain/entities/cam_relation.dart';

class CamExpressionRelationModel {
  final String targetParamName;
  final String expression;

  const CamExpressionRelationModel({
    required this.targetParamName,
    required this.expression,
  });

  factory CamExpressionRelationModel.fromEntity(CamExpressionRelation entity) {
    return CamExpressionRelationModel(
      targetParamName: entity.targetParamName,
      expression: entity.expression,
    );
  }

  CamExpressionRelation toEntity() {
    return CamExpressionRelation(
      targetParamName: targetParamName,
      expression: expression,
      referencedParamNames: const [],
    );
  }

  factory CamExpressionRelationModel.fromJson(Map<String, dynamic> json) {
    return CamExpressionRelationModel(
      targetParamName: json['targetParamName'],
      expression: json['expression'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'targetParamName': targetParamName, 'expression': expression};
  }
}

class CamHierarchyRelationModel {
  final String targetParamName;
  final String childParamName;

  const CamHierarchyRelationModel({
    required this.targetParamName,
    required this.childParamName,
  });

  factory CamHierarchyRelationModel.fromEntity(CamHierarchyRelation entity) {
    return CamHierarchyRelationModel(
      targetParamName: entity.targetParamName,
      childParamName: entity.childParamName,
    );
  }

  CamHierarchyRelation toEntity() {
    return CamHierarchyRelation(
      targetParamName: targetParamName,
      childParamName: childParamName,
    );
  }

  factory CamHierarchyRelationModel.fromJson(Map<String, dynamic> json) {
    return CamHierarchyRelationModel(
      targetParamName: json['targetParamName'],
      childParamName: json['childParamName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetParamName': targetParamName,
      'childParamName': childParamName,
    };
  }
}
