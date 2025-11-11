import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class SrtToTextFromTextPage extends StatelessWidget {
  const SrtToTextFromTextPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'text_conversion',
    toolName: 'Convert SRT to Text',
    categoryIcon: Icons.text_fields,
  );
}
