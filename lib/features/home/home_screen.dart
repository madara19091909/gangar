import 'package:flutter/material.dart';
import '../totem_skin/screens/totem_skin_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bedrock Tools', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF234D2C), Color(0xFF17251A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.extension_rounded, size: 38, color: Color(0xFF9AF0A8)),
                SizedBox(height: 18),
                Text('Minecraft Bedrock tools', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                SizedBox(height: 8),
                Text('Create resource packs on your phone. Your files are generated locally.'),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('TOOLS', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(color: const Color(0xFF2E5635), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.auto_awesome, size: 30, color: Color(0xFFB9FFC3)),
              ),
              title: const Text('Totem Skin Maker', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('Create a custom Totem resource pack and export it as .mcpack.'),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TotemSkinScreen()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.construction_outlined),
              title: Text('More tools coming later'),
              subtitle: Text('The project is organized so future tools can be added separately.'),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Compatibility note: pack generation is automated, but the texture path and in-game result must be verified against the target Bedrock version.',
            style: TextStyle(color: Colors.white60, height: 1.5),
          ),
        ],
      ),
    );
  }
}
