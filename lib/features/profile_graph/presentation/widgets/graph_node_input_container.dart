import 'package:flutter/material.dart';
import 'package:laminode_app/core/domain/entities/cam_param.dart';

class GraphNodeInputContainer extends StatelessWidget {
  final CamParameter? parameter;
  final String? overrideValue;
  final Color borderColor;

  const GraphNodeInputContainer({
    super.key,
    this.parameter,
    this.overrideValue,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        _getDisplayValue(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _getDisplayValue() {
    if (overrideValue != null) return overrideValue!;
    if (parameter == null) return '';

    if (parameter!.quantity.quantityType == QuantityType.numeric) {
      return '0.00 ${parameter!.quantity.quantityUnit}';
    } else if (parameter!.quantity.quantityType == QuantityType.boolean) {
      return 'Disabled';
    }
    return 'Select...';
  }
}
