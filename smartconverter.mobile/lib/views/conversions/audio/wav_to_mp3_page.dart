import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class WavToMp3Page extends StatelessWidget {
  const WavToMp3Page({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'audio_conversion',
    toolName: 'Convert WAV to MP3',
    categoryIcon: Icons.audiotrack_outlined,
  );
}
