import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/totem_pack_config.dart';
import '../services/totem_pack_builder.dart';

class TotemSkinScreen extends StatefulWidget {
  const TotemSkinScreen({super.key});

  @override
  State<TotemSkinScreen> createState() => _TotemSkinScreenState();
}

class _TotemSkinScreenState extends State<TotemSkinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: 'My Custom Totem');
  final _description = TextEditingController(text: 'A custom Totem resource pack.');
  final _author = TextEditingController();
  final _version = TextEditingController(text: '1.0.0');
  final _license = TextEditingController(text: 'All rights reserved');
  final _contact = TextEditingController();
  final _picker = ImagePicker();
  final _builder = TotemPackBuilder();

  Uint8List? _imageBytes;
  String? _imageName;
  bool _busy = false;
  File? _generatedFile;
  String? _status;
  bool _statusIsError = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _author.dispose();
    _version.dispose();
    _license.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
        _imageName = picked.name;
        _generatedFile = null;
        _status = null;
      });
    } catch (error) {
      _setStatus('Could not open image: $error', isError: true);
    }
  }

  Future<void> _generate() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_imageBytes == null) {
      _setStatus('Choose a texture image first.', isError: true);
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Building resource pack...';
      _statusIsError = false;
      _generatedFile = null;
    });

    try {
      final config = TotemPackConfig(
        packName: _name.text.trim(),
        description: _description.text.trim(),
        author: _author.text.trim(),
        version: _version.text.trim(),
        license: _license.text.trim(),
        contactUrl: _contact.text.trim(),
      );
      final temp = await getTemporaryDirectory();
      final result = await _builder.build(
        sourceImage: _imageBytes!,
        config: config,
        outputDirectory: Directory('${temp.path}/bedrock_tools'),
      );
      if (!mounted) return;
      setState(() {
        _generatedFile = result.file;
        _status = 'Pack created. Texture size: ${result.textureWidth} × ${result.textureHeight}. Import and test it in Minecraft.';
        _statusIsError = false;
      });
    } catch (error) {
      _setStatus('Build failed: $error', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _setStatus(String message, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _status = message;
      _statusIsError = isError;
    });
  }

  Future<void> _sharePack() async {
    final file = _generatedFile;
    if (file == null || !await file.exists()) {
      _setStatus('Generate the pack first.', isError: true);
      return;
    }
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/zip')],
      text: 'Minecraft Bedrock resource pack: ${_name.text.trim()}',
    );
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Totem Skin Maker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    height: 190,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF101710),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: _imageBytes == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined, size: 48, color: Colors.white54),
                              SizedBox(height: 10),
                              Text('Choose your custom texture'),
                              SizedBox(height: 4),
                              Text('PNG, JPG or WEBP input', style: TextStyle(color: Colors.white54)),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                          ),
                  ),
                  if (_imageName != null) ...[
                    const SizedBox(height: 8),
                    Text(_imageName!, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _pickImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Choose image'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _field(_name, 'Pack name', validator: (v) => _required(v, 'Pack name')),
                _field(_description, 'Description', maxLines: 3, validator: (v) => _required(v, 'Description')),
                _field(_author, 'Creator / team name', validator: (v) => _required(v, 'Creator name')),
                _field(_version, 'Version (X.Y.Z)', validator: (v) {
                  if (v == null || !RegExp(r'^\d+\.\d+\.\d+$').hasMatch(v.trim())) {
                    return 'Use a version such as 1.0.0.';
                  }
                  return null;
                }),
                _field(_license, 'Rights / license', validator: (v) => _required(v, 'Rights text')),
                _field(_contact, 'Contact URL (optional)', keyboardType: TextInputType.url),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _busy ? null : _generate,
            icon: _busy
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.inventory_2_outlined),
            label: Text(_busy ? 'Building...' : 'Generate .mcpack'),
          ),
          if (_status != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _statusIsError ? Colors.red.withValues(alpha: 0.12) : Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(_status!, style: TextStyle(color: _statusIsError ? Colors.redAccent : Colors.greenAccent)),
            ),
          ],
          if (_generatedFile != null) ...[
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _sharePack,
              icon: const Icon(Icons.share_outlined),
              label: const Text('Share / save pack'),
            ),
          ],
          const SizedBox(height: 18),
          const Text(
            'Important: this starter generator writes the selected image to a conventional totem texture path. Bedrock resource-pack texture paths can vary by version/template, so successful file generation is not proof that the in-game totem changed. Test the exported pack in a separate test world and verify the result.',
            style: TextStyle(color: Colors.white60, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(labelText: label, alignLabelWithHint: maxLines > 1),
      ),
    );
  }
}
