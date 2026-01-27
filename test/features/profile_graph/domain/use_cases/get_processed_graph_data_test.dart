import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';
import 'package:laminode_app/core/domain/entities/entries/cam_category_entry.dart';
import 'package:laminode_app/core/domain/entities/entries/param_entry.dart';
import 'package:laminode_app/core/services/graph_debug_service.dart';
import 'package:laminode_app/features/layer_panel/domain/entities/layer_entry.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_data.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:laminode_app/features/profile_graph/domain/use_cases/get_processed_graph_data.dart';
import 'package:laminode_app/features/profile_graph/domain/use_cases/get_profile_graph_data.dart';
import 'package:laminode_app/features/schema_editor/domain/entities/cam_schema_entry.dart';
import 'package:laminode_app/features/profile_graph/data/models/graph_node_model.dart';
import 'package:mocktail/mocktail.dart';
import 'package:laminode_app/features/evaluation/domain/evaluation_engine.dart';

class MockGetProfileGraphData extends Mock implements GetProfileGraphData {}
class MockEvaluationEngine extends Mock implements EvaluationEngine {}
class MockCamSchemaEntry extends Mock implements CamSchemaEntry {}
class MockLamiLayerEntry extends Mock implements LamiLayerEntry {}

void main() {
  late GetProcessedGraphData useCase;
  late MockGetProfileGraphData mockGetProfileGraphData;
  late MockEvaluationEngine mockEngine;

  setUp(() {
    mockGetProfileGraphData = MockGetProfileGraphData();
    mockEngine = MockEvaluationEngine();
    useCase = GetProcessedGraphData(mockGetProfileGraphData);
    
    // Silence talker
    // GraphDebugService.talker = Talker(logger: TalkerLogger(output: (l, m) {}));
  });

  const tCategoryName = 'cat1';
  final tCategory = CamCategoryEntry(
    categoryName: tCategoryName, 
    categoryTitle: 'Category 1',
    categoryColorName: 'blue',
  );
  
  final tParam = CamParamEntry(
    paramName: 'p1',
    paramTitle: 'Param 1',
    category: tCategory,
    quantity: const ParamQuantity(
      quantityName: 'generic', 
      quantityUnit: '', 
      quantitySymbol: '', 
      quantityType: QuantityType.numeric
    ),
    value: 10,
  );

  final tSchema = CamSchemaEntry(
    schemaName: 'Schema 1',
    categories: [tCategory],
    availableParameters: [tParam],
  );

  test('should return empty graph data if no schema and no active layers', () {
    final result = useCase.execute(
      activeSchema: null,
      layers: [],
      expandedParamName: null,
      lockedParams: {},
      branchedParamNames: {},
      engine: mockEngine,
    );

    expect(result.isEmpty, true);
  });

  test('should call GetProfileGraphData with correct data', () {
    // Arrange
    final layer = MockLamiLayerEntry();
    when(() => layer.isActive).thenReturn(true);
    when(() => layer.layerCategory).thenReturn(tCategoryName);
    when(() => layer.parameters).thenReturn(null);

    final tGraphData = GraphData(
      nodes: {'n1': GraphNodeModel(id: 'n1', label: '', shape: GraphNodeShape.none)}, 
      edges: {}
    );
    
    when(() => mockGetProfileGraphData.execute(
      categories: any(named: 'categories'),
      parameters: any(named: 'parameters'),
      parentToChildrenMap: any(named: 'parentToChildrenMap'),
      branchedParamNames: any(named: 'branchedParamNames'),
    )).thenReturn(tGraphData);

    // Act
    final result = useCase.execute(
      activeSchema: tSchema,
      layers: [layer],
      expandedParamName: null,
      lockedParams: {},
      branchedParamNames: {},
      engine: mockEngine,
    );

    // Assert
    verify(() => mockGetProfileGraphData.execute(
      categories: any(named: 'categories', that: isNotEmpty),
      parameters: any(named: 'parameters', that: isNotEmpty),
      parentToChildrenMap: any(named: 'parentToChildrenMap'),
      branchedParamNames: any(named: 'branchedParamNames'),
    )).called(1);
    
    expect(result, tGraphData);
  });

  test('should update node selection/focus/lock states', () {
    final layer = MockLamiLayerEntry();
    when(() => layer.isActive).thenReturn(true);
    when(() => layer.layerCategory).thenReturn(tCategoryName);
    when(() => layer.parameters).thenReturn(null);

    final tNode = GraphNodeModel(id: 'p1', label: '', shape: GraphNodeShape.none);
    final tGraphData = GraphData(nodes: {'p1': tNode}, edges: {});

     when(() => mockGetProfileGraphData.execute(
      categories: any(named: 'categories'),
      parameters: any(named: 'parameters'),
      parentToChildrenMap: any(named: 'parentToChildrenMap'),
      branchedParamNames: any(named: 'branchedParamNames'),
    )).thenReturn(tGraphData);

    final result = useCase.execute(
      activeSchema: tSchema,
      layers: [layer],
      expandedParamName: 'p1',
      focusedParamName: 'p1',
      lockedParams: {'p1': true},
      branchedParamNames: {},
      engine: mockEngine,
    );

    expect(result.nodes['p1']!.isSelected, true);
    expect(result.nodes['p1']!.isFocused, true);
    expect(result.nodes['p1']!.isLocked, true);
  });
}
