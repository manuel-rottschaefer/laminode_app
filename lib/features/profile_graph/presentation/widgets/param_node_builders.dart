import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/graph/hex/hex_layout.dart';
import 'package:laminode_app/features/profile_graph/domain/entities/graph_node.dart';
import 'package:laminode_app/features/profile_graph/presentation/utils/node_layout_calculator.dart';
import 'graph_node_input_container.dart';
import 'node_title.dart';
import 'hex_icon_button.dart';

class HexNodeBody extends StatelessWidget {
  final HexNodeLayoutData data;
  final ParamGraphNode node;
  final VoidCallback? onToggleLock;
  final VoidCallback? onToggleBranching;

  const HexNodeBody({
    super.key,
    required this.data,
    required this.node,
    this.onToggleLock,
    this.onToggleBranching,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HexLayout(
          circumradius: data.circumradius,
          scaleY: 1.0,
          children: [
            HexChild(
              anchor: HexAnchor.leftVertex,
              offset: const Offset(20.5, 0),
              child: HexIconButton(
                icon: node.isLocked
                    ? Icons.lock_rounded
                    : Icons.lock_open_rounded,
                onPressed: onToggleLock,
                isToggled: node.isLocked,
              ),
            ),
            HexChild(
              anchor: HexAnchor.rightVertex,
              offset: const Offset(-20.5, 0),
              child: HexIconButton(
                icon: Icons.call_split_rounded,
                onPressed: node.hasChildren ? onToggleBranching : null,
                isToggled: node.isBranching,
              ),
            ),
          ],
        ),
        HexLayout(
          circumradius: data.circumradius,
          scaleY: 1.0,
          children: [
            HexChild(
              anchor: HexAnchor.topEdge,
              offset: const Offset(0, 64),
              child: NodeTitle(lines: data.lines, widths: data.lineWidths),
            ),
            HexChild(
              anchor: HexAnchor.bottomEdge,
              offset: const Offset(0, -32),
              child: _InputContainer(
                parameter: node.parameter,
                borderColor: data.borderColor,
                width: data.hexSize.width * 0.38,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InputContainer extends StatelessWidget {
  final dynamic parameter;
  final Color borderColor;
  final double width;

  const _InputContainer({
    required this.parameter,
    required this.borderColor,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GraphNodeInputContainer(
        parameter: parameter,
        borderColor: borderColor,
      ),
    );
  }
}
