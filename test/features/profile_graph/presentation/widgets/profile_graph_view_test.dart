import 'package:flutter/material.dart';
import 'package:flutter_force_directed_graph/flutter_force_directed_graph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laminode_app/features/evaluation/application/profile_evaluation_provider.dart';
import 'package:laminode_app/features/layer_panel/presentation/providers/layer_panel_provider.dart';
import 'package:laminode_app/features/param_panel/presentation/providers/param_panel_provider.dart';
import 'package:laminode_app/features/profile_graph/application/controllers/profile_graph_controller.dart';
import 'package:laminode_app/features/profile_graph/application/providers/graph_providers.dart';
import 'package:laminode_app/features/profile_graph/application/providers/graph_snapshot_providers.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_data.dart';
import 'package:laminode_app/features/profile_graph/presentation/widgets/graph_controls.dart';
import 'package:laminode_app/features/profile_graph/presentation/widgets/profile_graph_view.dart';
import 'package:mocktail/mocktail.dart';

// Mock dependencies
class MockProfileGraphController extends Mock implements ProfileGraphController {}
class MockRef extends Mock implements Ref {}

// Notifiers
class MockParamPanelNotifier extends ParamPanelNotifier {
  @override
  ParamPanelState build() {
    return ParamPanelState();
  }
}

class MockLayerPanelNotifier extends LayerPanelNotifier {
   @override
  LayerPanelState build() {
    return LayerPanelState();
  }
}

void main() {
  late MockProfileGraphController mockController;
  late ForceDirectedGraphController<String> visualController;
  late MockRef mockRef;

  setUp(() {
    mockRef = MockRef();
    mockController = MockProfileGraphController();
    final graph = ForceDirectedGraph<String>();
    visualController = ForceDirectedGraphController(graph: graph);
    
    when(() => mockController.visualController).thenReturn(visualController);
    when(() => mockController.addListener(any())).thenReturn(null);
    when(() => mockController.removeListener(any())).thenReturn(null);
    when(() => mockController.center()).thenReturn(null);
    when(() => mockController.saveCurrentSnapshot()).thenAnswer((_) async {});
    when(() => mockController.loadSnapshot()).thenAnswer((_) async {});
  });

  Widget buildTestWidget() {
    return ProviderScope(
      overrides: [
        profileGraphControllerProvider.overrideWith((ref) => mockController),
        visualControllerProvider.overrideWithValue(visualController),
        paramPanelProvider.overrideWith(() => MockParamPanelNotifier()),
        graphDataProvider.overrideWith((ref) => const GraphData.empty()),
        profileEvaluationProvider.overrideWith((ref) => {}),
        paramPanelItemsProvider.overrideWith((ref) => []),
        layerPanelProvider.overrideWith(() => MockLayerPanelNotifier()),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: ProfileGraphView(),
        ),
      ),
    );
  }

  testWidgets('ProfileGraphView builds correctly', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(ForceDirectedGraphWidget<String>), findsOneWidget);
    expect(find.byType(FloatingGraphButton), findsWidgets);
  });

  testWidgets('Control buttons trigger controller actions', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Find save button (tooltip 'Save Snapshot')
    final saveButton = find.byTooltip('Save Snapshot');
    await tester.tap(saveButton);
    verify(() => mockController.saveCurrentSnapshot()).called(1);

    // Find load button
    final loadButton = find.byTooltip('Load Snapshot');
    await tester.tap(loadButton);
    verify(() => mockController.loadSnapshot()).called(1);
    
    // Find center button
    final centerButton = find.byTooltip('Center Graph');
    await tester.tap(centerButton);
    verify(() => mockController.center()).called(1);
  });
}