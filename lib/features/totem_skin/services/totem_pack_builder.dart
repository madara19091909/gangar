
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:image/image.dart' as img;

import '../../../core/minecraft/manifest_generator.dart';
import '../../../core/validation/pack_validator.dart';
import '../models/totem_pack_config.dart';

class PackBuildResult {
  const PackBuildResult({
    required this.file,
    required this.textureWidth,
    required this.textureHeight,
  });

  final File file;
  final int textureWidth;
  final int textureHeight;
}

class TotemPackBuilder {
  TotemPackBuilder({
    ManifestGenerator? manifestGenerator,
    PackValidator? validator,
  })  : _manifestGenerator =
            manifestGenerator ?? ManifestGenerator(),
        _validator = validator ?? const PackValidator();

  final ManifestGenerator _manifestGenerator;
  final PackValidator _validator;

  /// Builds a transparent, pixel-art totem icon.
  /// The silhouette stays totem-shaped, with colors sampled from the skin.
  Uint8List createTotemTexture(Uint8List sourceImage) {
    final decoded = img.decodeImage(sourceImage);

    if (decoded == null) {
      throw const FormatException(
        'تعذّر قراءة الصورة. جرّب PNG أو JPG أو WEBP.',
      );
    }

    final skin = img.copyResize(
      decoded,
      width: 64,
      height: 64,
      interpolation: img.Interpolation.nearest,
    );

    final out = img.Image(width: 64, height: 64, numChannels: 4);
    img.fill(out, color: img.ColorRgba8(0, 0, 0, 0));

    const outline = [42, 29, 18, 255];
    const goldDark = [116, 73, 24, 255];
    const gold = [226, 174, 61, 255];
    const goldLight = [255, 220, 112, 255];
    const eye = [45, 232, 195, 255];

    bool inside(int x, int y, int x1, int y1, int x2, int y2) {
      return x >= x1 && x <= x2 && y >= y1 && y <= y2;
    }

    bool shape(int x, int y) {
      final head = inside(x, y, 21, 7, 42, 24);
      final neck = inside(x, y, 28, 24, 35, 29);
      final armL = inside(x, y, 8, 27, 24, 37) ||
          inside(x, y, 5, 29, 10, 35);
      final armR = inside(x, y, 39, 27, 55, 37) ||
          inside(x, y, 53, 29, 58, 35);
      final body = inside(x, y, 20, 28, 43, 48);
      final legL = inside(x, y, 22, 47, 30, 57);
      final legR = inside(x, y, 33, 47, 41, 57);

      return head || neck || armL || armR || body || legL || legR;
    }

    List<int> sample(int sx, int sy) {
      final p = skin.getPixel(
        sx.clamp(0, 63).toInt(),
        sy.clamp(0, 63).toInt(),
      );

      return [
        p.r.toInt(),
        p.g.toInt(),
        p.b.toInt(),
        255,
      ];
    }

    void put(int x, int y, List<int> c) {
      if (x >= 0 && x < 64 && y >= 0 && y < 64) {
        out.setPixelRgba(x, y, c[0], c[1], c[2], c[3]);
      }
    }

    // Draw a dark one-pixel outline around the totem silhouette.
    for (var y = 5; y <= 59; y++) {
      for (var x = 3; x <= 60; x++) {
        if (!shape(x, y)) continue;

        var edge = false;

        for (final d in const [
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1],
        ]) {
          if (!shape(x + d[0], y + d[1])) {
            edge = true;
            break;
          }
        }

        if (edge) {
          put(x, y, outline);
        }
      }
    }

    // Fill the totem parts with colors sampled from the skin.
    for (var y = 7; y <= 57; y++) {
      for (var x = 5; x <= 58; x++) {
        if (!shape(x, y)) continue;
        if (out.getPixel(x, y).a.toInt() > 0) continue;

        int sx;
        int sy;

        if (inside(x, y, 21, 7, 42, 24)) {
          sx = 8 + ((x - 21) * 8 ~/ 22);
          sy = 8 + ((y - 7) * 8 ~/ 18);
        } else if (inside(x, y, 8, 27, 24, 37) ||
            inside(x, y, 39, 27, 55, 37) ||
            inside(x, y, 5, 29, 10, 35) ||
            inside(x, y, 53, 29, 58, 35)) {
          sx = 44 + ((x % 8) * 4 ~/ 8);
          sy = 20 + ((y - 27).clamp(0, 11) * 12 ~/ 11);
        } else {
          sx = 20 + ((x - 20).clamp(0, 23) * 8 ~/ 23);
          sy = 20 + ((y - 28).clamp(0, 20) * 12 ~/ 20);
        }

        put(x, y, sample(sx, sy));
      }
    }

    // Gold trim.
    for (var x = 20; x <= 43; x++) {
      put(x, 6, goldDark);

      if (x >= 22 && x <= 41) {
        put(x, 5, gold);
      }

      put(x, 25, gold);
    }

    for (var y = 27; y <= 38; y++) {
      put(7, y, goldDark);
      put(8, y, gold);
      put(55, y, gold);
      put(56, y, goldDark);
    }

    for (var x = 20; x <= 43; x++) {
      put(x, 39, goldDark);

      if (x >= 21 && x <= 42) {
        put(x, 40, gold);
      }
    }

    // Pixel eyes and central jewel.
    for (final x in [26, 36]) {
      put(x, 15, goldLight);
      put(x + 1, 15, goldLight);
      put(x, 16, eye);
      put(x + 1, 16, eye);
    }

    for (final p in const [
      [31, 31],
      [32, 30],
      [33, 31],
      [32, 32],
    ]) {
      put(p[0], p[1], goldLight);
    }

    return Uint8List.fromList(img.encodePng(out));
  }

  Future<PackBuildResult> build({
    required Uint8List sourceImage,
    required TotemPackConfig config,
    required Directory outputDirectory,
  }) async {
    final textureBytes = createTotemTexture(sourceImage);
    final decodedTexture = img.decodeImage(textureBytes)!;
    final manifestText = _manifestGenerator.encode(config);

    final manifestIssues =
        _validator.validateManifest(manifestText);

    if (manifestIssues.isNotEmpty) {
      throw StateError(manifestIssues.join('\n'));
    }

    final licenseText = [
      config.packName,
      'Author: ${config.author}',
      'Version: ${config.version}',
      'License: ${config.license}',
      if (config.contactUrl.trim().isNotEmpty)
        'Contact / page: ${config.contactUrl}',
      '',
      'Copyright notice supplied by the pack creator.',
      'This file records the creator-provided terms; '
          'it does not technically prevent copying.',
    ].join('\n');

    final atlas = {
      'resource_pack_name': config.packName,
      'texture_name': 'atlas.items',
      'texture_data': {
        'totem': {
          'textures': 'textures/items/totem',
        },
      },
    };

    final archive = Archive();

    _addText(archive, 'manifest.json', manifestText);
    _addText(archive, 'LICENSE.txt', licenseText);
    _addText(
      archive,
      'textures/item_texture.json',
      const JsonEncoder.withIndent('  ').convert(atlas),
    );

    archive.addFile(
      ArchiveFile(
        'textures/items/totem.png',
        textureBytes.length,
        textureBytes,
      ),
    );

    final encoded = ZipEncoder().encode(archive);

    if (encoded == null || encoded.isEmpty) {
      throw StateError('تعذّر إنشاء ملف mcpack.');
    }

    await outputDirectory.create(recursive: true);

    final safeName = _safeFileName(config.packName);
    final output = File(
      '${outputDirectory.path}/$safeName.mcpack',
    );

    await output.writeAsBytes(encoded, flush: true);

    return PackBuildResult(
      file: output,
      textureWidth: decodedTexture.width,
      textureHeight: decodedTexture.height,
    );
  }

  void _addText(Archive archive, String path, String value) {
    final bytes = utf8.encode(value);
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  String _safeFileName(String value) {
    final cleaned = value
        .trim()
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');

    return cleaned.isEmpty ? 'custom_totem_pack' : cleaned;
  }
}
