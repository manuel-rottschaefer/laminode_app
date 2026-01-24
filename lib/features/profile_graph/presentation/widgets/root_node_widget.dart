import 'package:flutter/material.dart';
import '../../domain/entities/graph_node.dart';

class RootNodeWidget extends StatelessWidget {
  final RootGraphNode node;
  final VoidCallback? onTap;

  const RootNodeWidget({super.key, required this.node, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          node.label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: node.isFocused ? Colors.blue : Colors.grey.shade700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
