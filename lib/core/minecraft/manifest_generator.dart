import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../features/totem_skin/models/totem_pack_config.dart';

class ManifestGenerator {
  ManifestGenerator({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  Map<String, dynamic> generate(TotemPackConfig config) {
    final version = config.versionParts;
    return {
      'format_version': 2,
      'header': {
        'name': config.packName.trim(),
        'description': config.description.trim(),
        'uuid': _uuid.v4(),
        'version': version,
        'min_engine_version': [1, 20, 0],
      },
      'modules': [
        {
          'type': 'resources',
          'uuid': _uuid.v4(),
          'version': version,
        }
      ],
      'metadata': {
        'authors': [config.author.trim()],
        'license': config.license.trim(),
        if (config.contactUrl.trim().isNotEmpty) 'url': config.contactUrl.trim(),
      },
    };
  }

  String encode(TotemPackConfig config) => const JsonEncoder.withIndent('  ').convert(generate(config));
}
