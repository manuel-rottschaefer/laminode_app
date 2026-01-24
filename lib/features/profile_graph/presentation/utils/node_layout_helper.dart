import 'package:flutter/material.dart';

mixin NodeLayoutHelper {
  static List<String> getWords(String title) {
    final regExp = RegExp(
      r'(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])|[\s_]+',
    );
    return title.split(regExp).where((s) => s.isNotEmpty).toList();
  }

  static List<String>? tryFitWithoutEllipsis(
    List<String> words,
    TextStyle style,
    List<double> widths,
  ) {
    final lines = <String>[];
    int idx = 0;

    for (int i = 0; i < widths.length; i++) {
      if (idx >= words.length) {
        lines.add('');
        continue;
      }

      final buf = StringBuffer();
      final fitFactor = (i == widths.length - 1) ? 0.98 : 0.90;

      while (idx < words.length) {
        final candidate = buf.isEmpty
            ? words[idx]
            : '${buf.toString()} ${words[idx]}';
        final tp = TextPainter(
          text: TextSpan(text: candidate, style: style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();

        if (tp.width <= widths[i] * fitFactor) {
          if (buf.isNotEmpty) buf.write(' ');
          buf.write(words[idx]);
          idx++;
        } else {
          break;
        }
      }

      if (buf.isEmpty) {
        return null;
      }

      lines.add(buf.toString());
    }

    if (idx < words.length) return null;
    return lines;
  }

  static List<String> buildFallbackWithEllipsis(
    List<String> words,
    TextStyle style,
    List<double> widths,
  ) {
    final lines = <String>[];
    int idx = 0;

    for (int i = 0; i < 3; i++) {
      final buf = StringBuffer();
      while (idx < words.length) {
        final candidate = buf.isEmpty
            ? words[idx]
            : '${buf.toString()} ${words[idx]}';
        final tp = TextPainter(
          text: TextSpan(text: candidate, style: style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();
        if (tp.width <= widths[i] * 0.90) {
          if (buf.isNotEmpty) buf.write(' ');
          buf.write(words[idx]);
          idx++;
        } else {
          break;
        }
      }
      lines.add(buf.toString());
    }

    final lastBuf = StringBuffer();
    while (idx < words.length) {
      final candidate = lastBuf.isEmpty
          ? words[idx]
          : '${lastBuf.toString()} ${words[idx]}';
      final testWithEllipsis = '$candidate...';
      final tp = TextPainter(
        text: TextSpan(text: testWithEllipsis, style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();

      if (tp.width <= widths[3]) {
        if (lastBuf.isNotEmpty) lastBuf.write(' ');
        lastBuf.write(words[idx]);
        idx++;
      } else {
        break;
      }
    }

    if (lastBuf.isEmpty && words.isNotEmpty) {
      // Nothing fits comfortably, force a single word
      lastBuf.write(words[idx]);
      idx++;
    }

    if (idx < words.length) {
      lines.add('${lastBuf.toString()}...');
    } else {
      lines.add(lastBuf.toString());
    }

    while (lines.length < 4) {
      lines.add('');
    }
    return lines;
  }
}
