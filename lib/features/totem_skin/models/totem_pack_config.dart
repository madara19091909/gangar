class TotemPackConfig {
  const TotemPackConfig({
    required this.packName,
    required this.description,
    required this.author,
    required this.version,
    required this.license,
    this.contactUrl = '',
  });

  final String packName;
  final String description;
  final String author;
  final String version;
  final String license;
  final String contactUrl;

  List<int> get versionParts {
    final parsed = version.split('.').map((part) => int.tryParse(part) ?? -1).toList();
    if (parsed.length != 3 || parsed.any((part) => part < 0)) {
      throw const FormatException('Version must use the format X.Y.Z, for example 1.0.0.');
    }
    return parsed;
  }
}
