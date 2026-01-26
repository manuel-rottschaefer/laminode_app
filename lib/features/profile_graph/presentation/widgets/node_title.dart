import 'package:flutter/material.dart';

class NodeTitle extends StatelessWidget {
  final List<String> lines;
  final List<double> widths;

  const NodeTitle({super.key, required this.lines, required this.widths});

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();

    const TextStyle textStyle = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      height: 1.1,
      shadows: [
        Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black45),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(lines.length, (index) {
        final line = lines[index];
        final width = index < widths.length ? widths[index] : null;

        return SizedBox(
          width: width, // Constrain width if provided
          child: Text(
            line,
            style: textStyle,
            textAlign: TextAlign.center,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }),
    );
  }
}
