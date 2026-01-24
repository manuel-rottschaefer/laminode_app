import 'package:flutter/material.dart';
import 'package:laminode_app/core/presentation/widgets/graph/hex/hex_layout.dart';
import 'package:laminode_app/core/presentation/widgets/graph/octagon/octagon_layout.dart';
import '../utils/node_layout_calculator.dart';
import 'graph_node_input_container.dart';
import 'node_title.dart';
import '../../domain/entities/graph_node.dart';

class HexNodeBody extends StatelessWidget {
  final HexNodeLayoutData data;
  final ParamGraphNode node;

  const HexNodeBody({super.key, required this.data, required this.node});

  @override
  Widget build(BuildContext context) {
    return HexLayout(
      circumradius: data.circumradius,
      scaleY: 0.92,
      children: [
        HexChild(
          anchor: HexAnchor.topEdge,
          offset: const Offset(0, 64),
          child: NodeTitle(lines: data.lines, widths: data.lineWidths),
        ),
        HexChild(
          anchor: HexAnchor.bottomEdge,
          offset: const Offset(0, -24),
          child: _InputContainer(
            parameter: node.parameter,
            borderColor: data.borderColor,
            width: data.hexSize.width * 0.42,
          ),
        ),
      ],
    );
  }
}

class OctagonNodeBody extends StatelessWidget {
  final OctagonNodeLayoutData data;
  final ParamGraphNode node;

  const OctagonNodeBody({super.key, required this.data, required this.node});

  @override
  Widget build(BuildContext context) {
    return OctagonLayout(
      circumradius: data.circumradius,
      rotationDegrees: 22.5,
      children: [
        OctagonChild(
          anchor: OctagonAnchor.topEdge,
          offset: const Offset(0, 64),
          child: NodeTitle(lines: data.lines, widths: data.lineWidths),
        ),
        OctagonChild(
          anchor: OctagonAnchor.bottomEdge,
          offset: const Offset(0, -24),
          child: _InputContainer(
            parameter: node.parameter,
            borderColor: data.borderColor,
            width: data.nodeSize.width * 0.5,
          ),
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
