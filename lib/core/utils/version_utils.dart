int compareVersions(String v1, String v2) {
  final v1Parts = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final v2Parts = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

  final maxLength = v1Parts.length > v2Parts.length
      ? v1Parts.length
      : v2Parts.length;

  for (var i = 0; i < maxLength; i++) {
    final p1 = i < v1Parts.length ? v1Parts[i] : 0;
    final p2 = i < v2Parts.length ? v2Parts[i] : 0;
    if (p1 > p2) return 1;
    if (p1 < p2) return -1;
  }
  return 0;
}
