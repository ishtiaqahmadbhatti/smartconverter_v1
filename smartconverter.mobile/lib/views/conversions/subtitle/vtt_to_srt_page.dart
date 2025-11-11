import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class VttToSrtPage extends StatelessWidget {
  const VttToSrtPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'VTT To SRT',
    categoryIcon: Icons.subtitles_outlined,
  );
}
