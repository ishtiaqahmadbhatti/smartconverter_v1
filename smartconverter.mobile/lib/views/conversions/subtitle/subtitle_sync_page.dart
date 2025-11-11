import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class SubtitleSyncPage extends StatelessWidget {
  const SubtitleSyncPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'Subtitle Sync',
    categoryIcon: Icons.subtitles_outlined,
  );
}
