import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';

void main() {
  final category = CamCategoryEntry(
    categoryName: 'TestCat',
    categoryTitle: 'Test Category',
    categoryColorName: 'red',
  );

  const quantity = ParamQuantity(
    quantityName: 'length',
    quantityUnit: 'mm',
    quantitySymbol: 'l',
    quantityType: QuantityType.numeric,
  );

  final param = CamParamEntry(
    paramName: 'p1',
    paramTitle: 'P1',
    category: category,
    value: '10',
    paramDescription: 'desc',
    quantity: quantity,
  );

  group('GraphNode Entities', () {
    test('RootGraphNode copyWith works', () {
      const node = RootGraphNode(id: 'r1', label: 'Root');
      final copy = node.copyWith(isSelected: true);

      expect(copy.id, node.id);
      expect(copy.label, node.label);
      expect(copy.isSelected, true);
      expect(node.isSelected, false);
    });

    test('HubGraphNode copyWith works', () {
      final node = HubGraphNode(id: 'h1', label: 'Hub', category: category);
      final copy = node.copyWith(isFocused: true);

      expect(copy.id, node.id);
      expect(copy.category, category);
      expect(copy.isFocused, true);
    });

    test('ParamGraphNode copyWith works', () {
      final node = ParamGraphNode(id: 'p1', label: 'Param', parameter: param);
      final copy = node.copyWith(isLocked: true);

      expect(copy.id, node.id);
      expect(copy.parameter, param);
      expect(copy.isLocked, true);
    });
  });
}
