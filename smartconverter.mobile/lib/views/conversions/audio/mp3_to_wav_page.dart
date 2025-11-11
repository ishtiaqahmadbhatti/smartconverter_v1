import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class Mp3ToWavPage extends StatelessWidget {
  const Mp3ToWavPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'audio_conversion',
    toolName: 'Convert MP3 to WAV',
    categoryIcon: Icons.audiotrack_outlined,
  );
}
