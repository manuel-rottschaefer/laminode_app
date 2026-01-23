class ExpressionParser {
  /// Extracts variable names from the given [expression].
  Set<String> extractVariableNames(String expression) {
    // Regex to match identifiers starting with a letter or underscore, 
    // followed by alphanumeric characters or underscores.
    final regex = RegExp(r'\b[a-zA-Z_][a-zA-Z0-9_]*\b');
    
    // TODO: Filter out reserved keywords (e.g., Math functions) if needed.
    
    return regex.allMatches(expression).map((m) => m.group(0)!).toSet();
  }
}
