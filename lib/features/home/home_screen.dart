import 'package:flutter/material.dart';
import '../../app/app_strings.dart';
import '../totem_skin/screens/totem_skin_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onToggleLanguage});

  final VoidCallback onToggleLanguage;

  @override
  Widget build(BuildContext context) {
    final ar = AppStrings.isArabic(context);
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1D3825),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF31563B)),
                        ),
                        child: const Icon(Icons.grid_view_rounded, color: Color(0xFF8EF0A5), size: 27),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('BEDROCK TOOLS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.4, fontSize: 15)),
                            const SizedBox(height: 3),
                            Text(
                              ar ? 'أدوات صُنّاع ماينكرافت' : 'Tools for Minecraft creators',
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: onToggleLanguage,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          side: const BorderSide(color: Color(0xFF34483A)),
                          foregroundColor: const Color(0xFFB9F7C5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(ar ? 'EN' : 'عربي', style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1C492C), Color(0xFF12251A), Color(0xFF111813)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: const Color(0xFF2B5537)),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -16,
                          top: -16,
                          child: Icon(Icons.view_in_ar_rounded, size: 136, color: Colors.white.withValues(alpha: .055)),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFF2B6C3E), borderRadius: BorderRadius.circular(30)),
                              child: Text(ar ? 'مختبر الإضافات' : 'ADD-ON LAB', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              ar ? 'اصنع إضافاتك\nبطريقتك.' : 'Build your packs.\nYour way.',
                              style: const TextStyle(fontSize: 30, height: 1.12, fontWeight: FontWeight.w900, letterSpacing: -.5),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              ar ? 'أدوات عملية لصناعة موارد ماينكرافت بيدروك من هاتفك، وملفاتك تبقى على جهازك.' : 'Practical tools for creating Minecraft Bedrock resources from your phone. Your files stay on your device.',
                              style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 13),
                            ),
                            const SizedBox(height: 22),
                            Row(
                              children: [
                                const Icon(Icons.phone_android_rounded, size: 17, color: Color(0xFF8EF0A5)),
                                const SizedBox(width: 7),
                                Text(ar ? 'مصمم للموبايل' : 'Made for mobile', style: const TextStyle(color: Color(0xFFBDF6C8), fontSize: 12, fontWeight: FontWeight.w700)),
                                const SizedBox(width: 18),
                                const Icon(Icons.folder_outlined, size: 17, color: Color(0xFF8EF0A5)),
                                const SizedBox(width: 7),
                                Text(ar ? 'تصدير مباشر' : 'Easy export', style: const TextStyle(color: Color(0xFFBDF6C8), fontSize: 12, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(child: Text(ar ? 'الأدوات' : 'TOOLS', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900))),
                      Text(ar ? '01 متاح' : '01 AVAILABLE', style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .8)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Material(
                    color: const Color(0xFF151E18),
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TotemSkinScreen())),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF293B2E))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(color: const Color(0xFF203D29), borderRadius: BorderRadius.circular(18)),
                                  child: const Icon(Icons.auto_awesome_rounded, size: 31, color: Color(0xFF9CF5AD)),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                  decoration: BoxDecoration(color: const Color(0xFF203D29), borderRadius: BorderRadius.circular(20)),
                                  child: Text(ar ? 'جاهز' : 'READY', style: const TextStyle(color: Color(0xFF9CF5AD), fontSize: 10, fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 17),
                            Text(ar ? 'مصمّم خامة التوتم' : 'Totem Skin Maker', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 7),
                            Text(
                              ar ? 'حوّل سكنك إلى خامة توتم، أضف اسمك وحقوقك، وصدّر حزمة موارد بصيغة mcpack.' : 'Turn your skin into a totem texture, add creator credits, and export a resource pack as .mcpack.',
                              style: const TextStyle(color: Colors.white60, height: 1.55, fontSize: 13),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Text(ar ? 'افتح الأداة' : 'OPEN TOOL', style: const TextStyle(color: Color(0xFF9CF5AD), fontWeight: FontWeight.w900, letterSpacing: .8, fontSize: 11)),
                                const Spacer(),
                                Icon(ar ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded, color: const Color(0xFF9CF5AD), size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF121914), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF222F26))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.tips_and_updates_outlined, color: Color(0xFF9CF5AD), size: 21),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ar ? 'نصيحة: جرّب أي حزمة جديدة في ماينكرافت قبل استخدامها بعالمك الأساسي.' : 'Tip: test every new pack in Minecraft before using it in your main world.',
                            style: const TextStyle(color: Colors.white60, height: 1.5, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Center(child: Text('BEDROCK TOOLS  •  ${ar ? 'صُنع للمبدعين' : 'MADE FOR CREATORS'}', style: const TextStyle(color: Colors.white30, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w700))),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
