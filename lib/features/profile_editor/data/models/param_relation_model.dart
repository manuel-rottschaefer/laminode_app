import 'package:laminode_app/core/data/models/param_entry_model.dart';
import 'package:laminode_app/core/domain/entities/cam_relation.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/features/profile_editor/domain/entities/param_relation_entry.dart';

class ParamRelationModel {
  final CamParamEntryModel targetParam;
  final String? expression;
  final List<String>? referencedParamNames;

  const ParamRelationModel({required this.targetParam, this.expression, this.referencedParamNames});

  factory ParamRelationModel.fromEntity(ParamRelationEntry entity) {
    return ParamRelationModel(
      targetParam: CamParamEntryModel.fromEntity(entity.targetParam as CamParamEntry),
      expression: entity.expression,
      referencedParamNames: entity.referencedParamNames,
    );
  }

  ParamRelationEntry toEntity() {
    return ParamRelationEntry(
      targetParam: targetParam.toEntity(),
      expression: expression ?? '',
      referencedParamNames: referencedParamNames,
    );
  }

  factory ParamRelationModel.fromJson(Map<String, dynamic> json) {
    return ParamRelationModel(
      targetParam: CamParamEntryModel.fromJson(json['targetParam'] as Map<String, dynamic>),
      expression: json['expression'],
      referencedParamNames: (json['referencedParamNames'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetParam': targetParam.toJson(),
      'expression': expression,
      'referencedParamNames': referencedParamNames,
    };
  }
}

class AncestorRelationModel {
  final CamParamEntryModel targetParam;
  final CamParamEntryModel ancestorParam;

  const AncestorRelationModel({required this.targetParam, required this.ancestorParam});

  factory AncestorRelationModel.fromEntity(AncestorRelation entity) {
    return AncestorRelationModel(
      targetParam: CamParamEntryModel.fromEntity(entity.targetParam as CamParamEntry),
      ancestorParam: CamParamEntryModel.fromEntity(entity.ancestorParam as CamParamEntry),
    );
  }

  AncestorRelation toEntity() {
    return AncestorRelation(targetParam: targetParam.toEntity(), ancestorParam: ancestorParam.toEntity());
  }

  factory AncestorRelationModel.fromJson(Map<String, dynamic> json) {
    return AncestorRelationModel(
      targetParam: CamParamEntryModel.fromJson(json['targetParam'] as Map<String, dynamic>),
      ancestorParam: CamParamEntryModel.fromJson(json['ancestorParam'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {'targetParam': targetParam.toJson(), 'ancestorParam': ancestorParam.toJson()};
  }
}
