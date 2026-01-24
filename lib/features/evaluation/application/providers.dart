import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laminode_app/features/evaluation/application/cam_relation_service.dart';
import 'package:laminode_app/features/evaluation/application/expression_parser.dart';
import 'package:laminode_app/features/evaluation/domain/evaluation_engine.dart';
import 'package:laminode_app/features/evaluation/infrastructure/js_evaluation_engine.dart';

final expressionParserProvider = Provider<ExpressionParser>((ref) {
  return ExpressionParser();
});

final evaluationEngineProvider = Provider<EvaluationEngine>((ref) {
  final engine = JsEvaluationEngine();
  ref.onDispose(() => engine.dispose());
  return engine;
});

final camRelationServiceProvider = Provider<CamRelationService>((ref) {
  final engine = ref.watch(evaluationEngineProvider);
  final parser = ref.watch(expressionParserProvider);
  return CamRelationService(engine, parser);
});
