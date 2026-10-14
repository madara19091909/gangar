import 'dart:convert';

class PackValidator {
  const PackValidator();

  List<String> validateManifest(String manifestText) {
    final issues = <String>[];
    dynamic decoded;
    try {
      decoded = jsonDecode(manifestText);
    } on FormatException {
      return ['manifest.json is not valid JSON.'];
    }

    if (decoded is! Map<String, dynamic>) return ['Manifest root must be a JSON object.'];
    if (decoded['format_version'] != 2) issues.add('Expected manifest format_version 2.');
    final header = decoded['header'];
    if (header is! Map<String, dynamic>) {
      issues.add('Missing header object.');
    } else {
      for (final key in ['name', 'description', 'uuid', 'version', 'min_engine_version']) {
        if (!header.containsKey(key)) issues.add('Missing header.$key.');
      }
    }
    final modules = decoded['modules'];
    if (modules is! List || modules.isEmpty) {
      issues.add('At least one module is required.');
    } else if (modules.first is Map && modules.first['type'] != 'resources') {
      issues.add('First module type must be resources.');
    }
    return issues;
  }
}
