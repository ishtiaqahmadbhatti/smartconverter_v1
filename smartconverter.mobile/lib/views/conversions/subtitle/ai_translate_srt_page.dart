import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AiTranslateSrtPage extends StatelessWidget {
  const AiTranslateSrtPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'AI: Translate SRT',
    categoryIcon: Icons.subtitles_outlined,
  );
}
