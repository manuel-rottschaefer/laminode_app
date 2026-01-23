import 'package:laminode_app/features/evaluation/domain/evaluation_engine.dart';

class EvaluationService {
  final EvaluationEngine _engine;

  EvaluationService(this._engine);

  dynamic evaluate(String expression, Map<String, dynamic> context) {
    return _engine.evaluate(expression, context);
  }
}
