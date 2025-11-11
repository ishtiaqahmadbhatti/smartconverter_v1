import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class FlacToWavPage extends StatelessWidget {
  const FlacToWavPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'audio_conversion',
    toolName: 'Convert FLAC to WAV',
    categoryIcon: Icons.audiotrack_outlined,
  );
}
