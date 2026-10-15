
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import '../../../app/app_strings.dart';
import '../models/totem_pack_config.dart';
import '../services/totem_pack_builder.dart';

class TotemSkinScreen extends StatefulWidget {
  const TotemSkinScreen({super.key});

  @override
  State<TotemSkinScreen> createState() => _TotemSkinScreenState();
}

class _TotemSkinScreenState extends State<TotemSkinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: 'Totem Skin');
  final _description =
      TextEditingController(text: 'Custom totem texture');
  final _author = TextEditingController();
  final _version = TextEditingController(text: '1.0.0');
  final _license =
      TextEditingController(text: 'All rights reserved');
  final _contact = TextEditingController();

  final _picker = ImagePicker();
  final _builder = TotemPackBuilder();

  Uint8List? _imageBytes;
  Uint8List? _previewBytes;
  String? _imageName;
  bool _busy = false;
  File? _generatedFile;
  String? _status;
  bool _statusIsError = false;

  String tr(BuildContext context, String ar, String en) =>
      AppStrings.t(context, ar, en);

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
    final errorPrefix = tr(
      context,
      'ما كدرت أفتح الصورة:',
      'Could not open image:',
    );

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (!mounted || picked == null) return;

      final bytes = await picked.readAsBytes();

      if (!mounted) return;

      final preview = _builder.createTotemTexture(bytes);

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _previewBytes = preview;
        _imageName = picked.name;
        _generatedFile = null;
        _status = null;
        _statusIsError = false;
      });
    } catch (error) {
      if (!mounted) return;
      _setStatus('$errorPrefix $error', isError: true);
    }
  }

  Future<void> _generate() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_imageBytes == null) {
      _setStatus(
        tr(
          context,
          'اختار صورة السكن أولاً.',
          'Choose a skin image first.',
        ),
        isError: true,
      );
      return;
    }

    final sourceImage = _imageBytes!;

    setState(() {
      _busy = true;
      _status = tr(
        context,
        'جاري تجهيز خامة التوتم...',
        'Building totem texture...',
      );
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
        sourceImage: sourceImage,
        config: config,
        outputDirectory: Directory(
          '${temp.path}/bedrock_tools',
        ),
      );

      if (!mounted) return;

      setState(() {
        _generatedFile = result.file;
        _status = tr(
          context,
          'تم إنشاء الحزمة. جرّب استيرادها داخل ماينكرافت.',
          'Pack created. Try importing it into Minecraft.',
        );
        _statusIsError = false;
      });
    } catch (error) {
      if (!mounted) return;

      _setStatus(
        '${tr(context, 'فشل الإنشاء:', 'Build failed:')} $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _setStatus(String message, {bool isError = false}) {
    if (!mounted) return;

    setState(() {
      _status = message;
      _statusIsError = isError;
    });
  }

  Future<void> _openInMinecraft() async {
    final file = _generatedFile;

    final missingMessage = tr(
      context,
      'أنشئ الحزمة أولاً.',
      'Generate the pack first.',
    );

    final successMessage = tr(
      context,
      'طلبنا من أندرويد فتح الحزمة. إذا ما ظهر ماينكرافت، جرّب المشاركة أو مدير الملفات.',
      'Android was asked to open the pack. If Minecraft does not appear, try Share or your file manager.',
    );

    final errorPrefix = tr(
      context,
      'تعذّر فتح الحزمة:',
      'Could not open the pack:',
    );

    if (file == null) {
      _setStatus(missingMessage, isError: true);
      return;
    }

    try {
      final exists = await file.exists();

      if (!mounted) return;

      if (!exists) {
        _setStatus(missingMessage, isError: true);
        return;
      }

      await OpenFilex.open(
        file.path,
        type: 'application/x-mcpack',
      );

      if (!mounted) return;

      _setStatus(successMessage);
    } catch (error) {
      if (!mounted) return;

      _setStatus(
        '$errorPrefix $error',
        isError: true,
      );
    }
  }

  Future<void> _sharePack() async {
    final file = _generatedFile;

    final missingMessage = tr(
      context,
      'أنشئ الحزمة أولاً.',
      'Generate the pack first.',
    );

    final shareText =
        '${tr(context, 'حزمة موارد ماينكرافت بيدروك:', 'Minecraft Bedrock resource pack:')} ${_name.text.trim()}';

    if (file == null) {
      _setStatus(missingMessage, isError: true);
      return;
    }

    try {
      final exists = await file.exists();

      if (!mounted) return;

      if (!exists) {
        _setStatus(missingMessage, isError: true);
        return;
      }

      await Share.shareXFiles(
        [
          XFile(
            file.path,
            mimeType: 'application/x-mcpack',
            name: '${_name.text.trim()}.mcpack',
          ),
        ],
        text: shareText,
      );
    } catch (error) {
      if (!mounted) return;

      _setStatus(
        '${tr(context, 'فشلت مشاركة الحزمة:', 'Sharing failed:')} $error',
        isError: true,
      );
    }
  }

  String? _required(
    String? value,
    BuildContext context,
    String ar,
    String en,
  ) {
    if (value == null || value.trim().isEmpty) {
      return tr(context, '$ar مطلوب.', '$en is required.');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr(context, 'مصمّم التوتم', 'Totem Skin Maker'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1C482A),
                  Color(0xFF121B15),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: const Color(0xFF2B5537),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A6038),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 29,
                    color: Color(0xFFB6FFC3),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tr(
                          context,
                          'خامة توتم بطابعك',
                          'Your own totem texture',
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        tr(
                          context,
                          'اختار السكن، أضف بياناتك، وصدّر الحزمة.',
                          'Choose a skin, add your credits, and export the pack.',
                        ),
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.4,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr(context, '١. صورة السكن', '1. Skin image'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 210,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C120E),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF2B3A2F),
                      ),
                    ),
                    child: _imageBytes == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image_search_rounded,
                                size: 46,
                                color: Color(0xFF78C88B),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                tr(
                                  context,
                                  'اختار صورة السكن من جهازك',
                                  'Choose a skin image from your device',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                tr(
                                  context,
                                  'الأفضل استخدام صورة سكن ماينكرافت',
                                  'A Minecraft skin image works best',
                                ),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.memory(
                              _previewBytes ?? _imageBytes!,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.none,
                            ),
                          ),
                  ),
                  if (_imageName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _imageName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _pickImage,
                      icon: const Icon(
                        Icons.add_photo_alternate_outlined,
                      ),
                      label: Text(
                        tr(context, 'اختيار صورة', 'Choose image'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(
                        context,
                        '٢. معلومات الحزمة',
                        '2. Pack details',
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _field(
                      _name,
                      tr(context, 'اسم الحزمة', 'Pack name'),
                      validator: (v) => _required(
                        v,
                        context,
                        'اسم الحزمة',
                        'Pack name',
                      ),
                    ),
                    _field(
                      _description,
                      tr(context, 'الوصف', 'Description'),
                      maxLines: 2,
                      validator: (v) => _required(
                        v,
                        context,
                        'الوصف',
                        'Description',
                      ),
                    ),
                    _field(
                      _author,
                      tr(
                        context,
                        'اسمك أو اسم الفريق',
                        'Creator / team name',
                      ),
                      validator: (v) => _required(
                        v,
                        context,
                        'اسم المنشئ',
                        'Creator name',
                      ),
                    ),
                    _field(
                      _version,
                      tr(
                        context,
                        'الإصدار (X.Y.Z)',
                        'Version (X.Y.Z)',
                      ),
                      validator: (v) {
                        if (v == null ||
                            !RegExp(r'^\d+\.\d+\.\d+$')
                                .hasMatch(v.trim())) {
                          return tr(
                            context,
                            'اكتب الإصدار مثل 1.0.0',
                            'Use a version such as 1.0.0.',
                          );
                        }

                        return null;
                      },
                    ),
                    _field(
                      _license,
                      tr(
                        context,
                        'الحقوق والترخيص',
                        'Rights / license',
                      ),
                      validator: (v) => _required(
                        v,
                        context,
                        'نص الحقوق',
                        'Rights text',
                      ),
                    ),
                    _field(
                      _contact,
                      tr(
                        context,
                        'رابط التواصل (اختياري)',
                        'Contact URL (optional)',
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: _busy ? null : _generate,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.inventory_2_rounded),
              label: Text(
                _busy
                    ? tr(context, 'جاري الإنشاء...', 'Building...')
                    : tr(
                        context,
                        'إنشاء ملف mcpack',
                        'Generate .mcpack',
                      ),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          if (_status != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _statusIsError
                    ? Colors.red.withValues(alpha: .12)
                    : const Color(0xFF183522),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _statusIsError
                      ? Colors.red.withValues(alpha: .35)
                      : const Color(0xFF2C6840),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _statusIsError
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    color: _statusIsError
                        ? Colors.redAccent
                        : const Color(0xFF9CF5AD),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _status!,
                      style: TextStyle(
                        color: _statusIsError
                            ? Colors.redAccent
                            : const Color(0xFFC8F5D1),
                        height: 1.45,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_generatedFile != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _openInMinecraft,
                icon: const Icon(Icons.sports_esports_rounded),
                label: Text(
                  tr(
                    context,
                    'فتح في ماينكرافت',
                    'Open in Minecraft',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _sharePack,
                icon: const Icon(Icons.share_rounded),
                label: Text(
                  tr(
                    context,
                    'مشاركة / حفظ الملف',
                    'Share / save pack',
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF121914),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF9CF5AD),
                  size: 19,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tr(
                      context,
                      'ملاحظة: استيراد الحزمة وظهور الخامة يعتمد على توافق مسار الخامة مع إصدار ماينكرافت. اختبرها قبل استخدامها بعالمك الأساسي.',
                      'Note: importing the pack and rendering the texture depend on the texture path supported by your Minecraft version. Test it before using it in your main world.',
                    ),
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
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
        textDirection: Directionality.of(context),
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: maxLines > 1,
        ),
      ),
    );
  }
}
