import 'package:laminode_app/features/evaluation/application/expression_parser.dart';
import 'package:laminode_app/features/profile_editor/domain/entities/param_relation_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';

class RelationEnrichmentService {
  final ExpressionParser _parser;

  RelationEnrichmentService(this._parser);

  /// Enriches a [ParamRelationEntry] by resolving parameter names found in its expression
  /// against the provided [availableParams].
  ParamRelationEntry enrich(ParamRelationEntry relation, List<CamParamEntry> availableParams) {
    final variableNames = _parser.extractVariableNames(relation.expression);
    
    final referencedParams = availableParams.where((param) {
      return variableNames.contains(param.paramName);
    }).toList();

    return relation.copyWith(
      referencedParamNames: referencedParams,
    );
  }
}
