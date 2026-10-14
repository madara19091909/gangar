import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:image/image.dart' as img;
import '../../core/minecraft/manifest_generator.dart';
import '../../core/validation/pack_validator.dart';
import '../models/totem_pack_config.dart';

class PackBuildResult {
  const PackBuildResult({required this.file, required this.textureWidth, required this.textureHeight});
  final File file;
  final int textureWidth;
  final int textureHeight;
}

class TotemPackBuilder {
  TotemPackBuilder({ManifestGenerator? manifestGenerator, PackValidator? validator})
      : _manifestGenerator = manifestGenerator ?? ManifestGenerator(),
        _validator = validator ?? const PackValidator();

  final ManifestGenerator _manifestGenerator;
  final PackValidator _validator;

  Future<PackBuildResult> build({
    required Uint8List sourceImage,
    required TotemPackConfig config,
    required Directory outputDirectory,
  }) async {
    final decoded = img.decodeImage(sourceImage);
    if (decoded == null) {
      throw const FormatException('Could not read this image. Try a PNG, JPG, or WEBP image.');
    }

    final pngBytes = img.encodePng(decoded);
    final manifestText = _manifestGenerator.encode(config);
    final manifestIssues = _validator.validateManifest(manifestText);
    if (manifestIssues.isNotEmpty) throw StateError(manifestIssues.join('\n'));

    final licenseText = [
      config.packName,
      'Author: ${config.author}',
      'Version: ${config.version}',
      'License: ${config.license}',
      if (config.contactUrl.trim().isNotEmpty) 'Contact / page: ${config.contactUrl}',
      '',
      'Copyright notice supplied by the pack creator.',
      'This file records the creator-provided terms; it does not technically prevent copying.',
    ].join('\n');

    final atlas = {
      'resource_pack_name': config.packName,
      'texture_name': 'atlas.items',
      'texture_data': {
        'totem': {'textures': 'textures/items/totem'}
      },
    };

    final archive = Archive();
    _addText(archive, 'manifest.json', manifestText);
    _addText(archive, 'LICENSE.txt', licenseText);
    _addText(archive, 'textures/item_texture.json', const JsonEncoder.withIndent('  ').convert(atlas));
    archive.addFile(ArchiveFile('textures/items/totem.png', pngBytes.length, pngBytes));

    final encoded = ZipEncoder().encode(archive);
    if (encoded == null || encoded.isEmpty) throw StateError('Could not create the .mcpack archive.');

    await outputDirectory.create(recursive: true);
    final safeName = _safeFileName(config.packName);
    final output = File('${outputDirectory.path}/$safeName.mcpack');
    await output.writeAsBytes(encoded, flush: true);
    return PackBuildResult(file: output, textureWidth: decoded.width, textureHeight: decoded.height);
  }

  void _addText(Archive archive, String path, String value) {
    final bytes = utf8.encode(value);
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  String _safeFileName(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    return cleaned.isEmpty ? 'custom_totem_pack' : cleaned;
  }
}
