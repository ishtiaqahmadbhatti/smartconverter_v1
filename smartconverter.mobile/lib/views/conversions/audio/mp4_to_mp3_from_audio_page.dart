import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class Mp4ToMp3FromAudioPage extends StatelessWidget {
  const Mp4ToMp3FromAudioPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'audio_conversion',
    toolName: 'Convert MP4 to MP3',
    categoryIcon: Icons.audiotrack_outlined,
  );
}
