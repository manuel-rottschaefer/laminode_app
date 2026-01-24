import 'package:flutter/material.dart';
import 'package:laminode_app/core/theme/app_spacing.dart';
import 'package:laminode_app/core/presentation/widgets/lami_segmented_control.dart';
import 'package:laminode_app/features/param_panel/domain/entities/param_panel_item.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_info_box.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_value_box.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_relation_tab.dart';
import 'package:laminode_app/features/param_panel/presentation/widgets/param_layers_tab.dart';

enum ParamTab { info, value, relation, layers }

class ParamListItemBody extends StatefulWidget {
  final ParamPanelItem item;

  const ParamListItemBody({super.key, required this.item});

  @override
  State<ParamListItemBody> createState() => _ParamListItemBodyState();
}

class _ParamListItemBodyState extends State<ParamListItemBody> {
  ParamTab _selectedTab = ParamTab.value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 0, 4.0, AppSpacing.m),
      child: Column(
        children: [
          LamiSegmentedControl<ParamTab>(
            selectedValue: _selectedTab,
            onSelected: (tab) => setState(() => _selectedTab = tab),
            segments: const [
              LamiSegment(
                value: ParamTab.info,
                icon: Icons.info_outline_rounded,
                tooltip: "Information",
              ),
              LamiSegment(
                value: ParamTab.value,
                icon: Icons.tune_rounded,
                tooltip: "Value & Constraints",
              ),
              LamiSegment(
                value: ParamTab.relation,
                icon: Icons.hub_outlined,
                tooltip: "Relations",
              ),
              LamiSegment(
                value: ParamTab.layers,
                icon: Icons.layers_outlined,
                tooltip: "Layer Stack",
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _buildActiveTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTab() {
    switch (_selectedTab) {
      case ParamTab.info:
        return ParamInfoBox(
          param: widget.item.param,
          description: widget.item.param.paramDescription,
        );
      case ParamTab.value:
        return ParamValueBox(item: widget.item);
      case ParamTab.relation:
        return ParamRelationTab(param: widget.item.param);
      case ParamTab.layers:
        return ParamLayersTab(param: widget.item.param);
    }
  }
}
