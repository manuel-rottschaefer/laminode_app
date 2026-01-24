import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:laminode_app/features/profile_graph/domain/use_cases/get_profile_graph_data.dart';

void main() {
  late GetProfileGraphData useCase;

  setUp(() {
    useCase = GetProfileGraphData();
  });

  final category = CamCategoryEntry(
    categoryName: 'Speed',
    categoryTitle: 'Speed Settings',
    categoryColorName: 'blue',
  );

  final category2 = CamCategoryEntry(
    categoryName: 'Quality',
    categoryTitle: 'Quality Settings',
    categoryColorName: 'green',
  );

  const quantitySpeed = ParamQuantity(
    quantityName: 'speed',
    quantityUnit: 'mm/s',
    quantitySymbol: 'v',
    quantityType: QuantityType.numeric,
  );

  const quantityLength = ParamQuantity(
    quantityName: 'length',
    quantityUnit: 'mm',
    quantitySymbol: 'l',
    quantityType: QuantityType.numeric,
  );

  final param1 = CamParamEntry(
    paramName: 'speed_print',
    paramTitle: 'Print Speed',
    category: category,
    value: '60',
    paramDescription: 'Speed of printing',
    quantity: quantitySpeed,
  );

  final param2 = CamParamEntry(
    paramName: 'speed_travel',
    paramTitle: 'Travel Speed',
    category: category,
    value: '120',
    paramDescription: 'Speed of travel',
    quantity: quantitySpeed,
    baseParam: 'speed_print',
  );

  final param3 = CamParamEntry(
    paramName: 'layer_height',
    paramTitle: 'Layer Height',
    category: category2,
    value: '0.2',
    paramDescription: 'Height of layer',
    quantity: quantityLength,
  );

  test('Should create root nodes for categories', () {
    final result = useCase.execute(categories: [category], parameters: []);

    expect(result.nodes.length, 1);
    expect(result.nodes.containsKey('__root_Speed'), true);
    expect(result.nodes['__root_Speed'], isA<RootGraphNode>());
  });

  test('Should create param nodes and connect to root if no parent', () {
    final result = useCase.execute(
      categories: [category],
      parameters: [param1],
    );

    expect(result.nodes.length, 2); // Root + Param
    expect(result.nodes.containsKey('speed_print'), true);
    expect(
      result.edges.any(
        (e) => e.sourceId == '__root_Speed' && e.targetId == 'speed_print',
      ),
      true,
    );
  });

  test('Should connect child to parent if hierarchical map provided', () {
    final result = useCase.execute(
      categories: [category],
      parameters: [param1, param2],
      parentToChildrenMap: {
        'speed_print': ['speed_travel'],
      },
    );

    expect(result.nodes.length, 3); // Root + Param1 + Param2

    // Check edge from Root -> Param1
    expect(
      result.edges.any(
        (e) => e.sourceId == '__root_Speed' && e.targetId == 'speed_print',
      ),
      true,
    );

    // Check edge from Param1 -> Param2
    expect(
      result.edges.any(
        (e) => e.sourceId == 'speed_print' && e.targetId == 'speed_travel',
      ),
      true,
    );

    // Ensure Param2 is NOT connected to Root directly
    expect(
      result.edges.any(
        (e) => e.sourceId == '__root_Speed' && e.targetId == 'speed_travel',
      ),
      false,
    );
  });

  test('Should handle multiple categories correctly', () {
    final result = useCase.execute(
      categories: [category, category2],
      parameters: [param1, param3],
    );
    expect(result.nodes.length, 4); // Root1, Root2, Param1, Param3
    expect(result.nodes['__root_Speed'], isNotNull);
    expect(result.nodes['__root_Quality'], isNotNull);

    expect(
      result.edges.any(
        (e) => e.sourceId == '__root_Speed' && e.targetId == 'speed_print',
      ),
      true,
    );
    expect(
      result.edges.any(
        (e) => e.sourceId == '__root_Quality' && e.targetId == 'layer_height',
      ),
      true,
    );
  });
}
