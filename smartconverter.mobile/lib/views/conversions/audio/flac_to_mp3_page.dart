import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class FlacToMp3Page extends StatelessWidget {
  const FlacToMp3Page({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'audio_conversion',
    toolName: 'Convert FLAC to MP3',
    categoryIcon: Icons.audiotrack_outlined,
  );
}
