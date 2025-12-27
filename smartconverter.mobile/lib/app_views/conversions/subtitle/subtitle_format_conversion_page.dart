import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class SubtitleFormatConversionPage extends StatelessWidget {
  const SubtitleFormatConversionPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'Subtitle Format Conversion',
    categoryIcon: Icons.subtitles_outlined,
  );
}
