import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class WavToFlacPage extends StatelessWidget {
  const WavToFlacPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'audio_conversion',
    toolName: 'Convert WAV to FLAC',
    categoryIcon: Icons.audiotrack_outlined,
  );
}
