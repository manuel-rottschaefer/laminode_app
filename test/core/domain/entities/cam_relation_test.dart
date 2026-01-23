import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/cam_relation.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';

void main() {
  final testCategory = CamCategoryEntry(categoryName: 'test', categoryTitle: 'Test', categoryColorName: 'blue');

  final testQuantity = const ParamQuantity(
    quantityName: 'n',
    quantityUnit: 'u',
    quantitySymbol: 's',
    quantityType: QuantityType.numeric,
  );

  final targetParam = _TestParam(
    paramName: 'target',
    paramTitle: 'Target',
    quantity: testQuantity,
    category: testCategory,
  );

  final ancestorParam = _TestParam(
    paramName: 'ancestor',
    paramTitle: 'Ancestor',
    quantity: testQuantity,
    category: testCategory,
  );

  group('Relation Entities', () {
    test('ValueRelation should hold targetParam and expression', () {
      final rel = ValueRelation(targetParam: targetParam, expression: '1 + 1');
      expect(rel.targetParam.paramName, 'target');
      expect(rel.expression, '1 + 1');
    });

    test('AncestorRelation should hold targetParam and ancestorParam', () {
      final rel = AncestorRelation(targetParam: targetParam, ancestorParam: ancestorParam);
      expect(rel.targetParam.paramName, 'target');
      expect(rel.ancestorParam.paramName, 'ancestor');
    });
  });
}

class _TestParam extends CamParameter {
  _TestParam({required super.paramName, required super.paramTitle, required super.quantity, required super.category});
}
