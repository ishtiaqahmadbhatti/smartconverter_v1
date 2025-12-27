import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AudioCompressPage extends StatelessWidget {
  const AudioCompressPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'audio_conversion',
    toolName: 'Audio Compress',
    categoryIcon: Icons.audiotrack_outlined,
  );
}
