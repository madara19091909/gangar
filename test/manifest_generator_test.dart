import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedrock_tools/core/minecraft/manifest_generator.dart';
import 'package:bedrock_tools/core/validation/pack_validator.dart';
import 'package:bedrock_tools/features/totem_skin/models/totem_pack_config.dart';

void main() {
  const config = TotemPackConfig(
    packName: 'Test Totem',
    description: 'Test description',
    author: 'Test creator',
    version: '1.0.0',
    license: 'All rights reserved',
  );

  test('manifest is valid JSON and passes basic validation', () {
    final text = ManifestGenerator().encode(config);
    expect(jsonDecode(text), isA<Map<String, dynamic>>());
    expect(const PackValidator().validateManifest(text), isEmpty);
  });

  test('manifest module and header UUIDs are different', () {
    final manifest = ManifestGenerator().generate(config);
    final header = manifest['header'] as Map<String, dynamic>;
    final module = (manifest['modules'] as List).first as Map<String, dynamic>;
    expect(header['uuid'], isNot(module['uuid']));
  });

  test('invalid version is rejected', () {
    const invalid = TotemPackConfig(
      packName: 'Test',
      description: 'Test',
      author: 'Creator',
      version: 'one',
      license: 'Custom',
    );
    expect(() => ManifestGenerator().generate(invalid), throwsFormatException);
  });
}
