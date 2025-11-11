import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PowerPointToTextPage extends StatelessWidget {
  const PowerPointToTextPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'text_conversion',
    toolName: 'Convert PowerPoint to Text',
    categoryIcon: Icons.text_fields,
  );
}
