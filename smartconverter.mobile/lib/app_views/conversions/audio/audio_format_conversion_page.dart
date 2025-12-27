import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AudioFormatConversionPage extends StatelessWidget {
  const AudioFormatConversionPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'audio_conversion',
    toolName: 'Audio Format Conversion',
    categoryIcon: Icons.audiotrack_outlined,
  );
}
