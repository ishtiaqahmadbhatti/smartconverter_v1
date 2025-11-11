import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AudioExtractPage extends StatelessWidget {
  const AudioExtractPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'audio_conversion',
    toolName: 'Audio Extract',
    categoryIcon: Icons.audiotrack_outlined,
  );
}
