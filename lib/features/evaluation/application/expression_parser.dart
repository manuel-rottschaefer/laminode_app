class ExpressionParser {
  static const _reservedKeywords = {
    'Math',
    'Object',
    'Array',
    'String',
    'Number',
    'Boolean',
    'Date',
    'RegExp',
    'Error',
    'EvalError',
    'RangeError',
    'ReferenceError',
    'SyntaxError',
    'TypeError',
    'URIError',
    'Infinity',
    'NaN',
    'undefined',
    'null',
    'true',
    'false',
    'if',
    'else',
    'return',
    'var',
    'let',
    'const',
    'function',
    'this',
  };

  /// Extracts variable names from the given [expression].
  Set<String> extractVariableNames(String expression) {
    if (expression.isEmpty) return {};

    // Regex to match identifiers starting with a letter or underscore,
    // followed by alphanumeric characters or underscores.
    final regex = RegExp(r'\b[a-zA-Z_][a-zA-Z0-9_]*\b');

    return regex
        .allMatches(expression)
        .map((m) => m.group(0)!)
        .where((name) => !_reservedKeywords.contains(name))
        .toSet();
  }
}
