import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AudioQualityPage extends StatelessWidget {
  const AudioQualityPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'audio_conversion',
    toolName: 'Audio Quality',
    categoryIcon: Icons.audiotrack_outlined,
  );
}
