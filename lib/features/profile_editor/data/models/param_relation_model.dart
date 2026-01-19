import 'package:laminode_app/core/data/models/param_entry_model.dart';
import 'package:laminode_app/features/profile_editor/domain/entities/param_relation_entry.dart';

class ParamRelationModel extends ParamRelationEntry {
  ParamRelationModel({
    required super.targetParam,
    required super.expression,
    super.referencedParamNames,
  });

  factory ParamRelationModel.fromJson(Map<String, dynamic> json) {
    return ParamRelationModel(
      targetParam: CamParamEntryModel.fromJson(
        json['targetParam'] as Map<String, dynamic>,
      ),
      expression: json['expression'],
      referencedParamNames: (json['referencedParamNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetParam': (targetParam as CamParamEntryModel).toJson(),
      'expression': expression,
      'referencedParamNames': referencedParamNames,
    };
  }
}
