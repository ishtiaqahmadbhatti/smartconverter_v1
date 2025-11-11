import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class VttToTextPage extends StatelessWidget {
  const VttToTextPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'subtitle_conversion',
    toolName: 'Convert VTT to Text',
    categoryIcon: Icons.subtitles_outlined,
  );
}
