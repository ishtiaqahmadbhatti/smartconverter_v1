import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class TextToWordPage extends StatelessWidget {
  const TextToWordPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'text_conversion',
    toolName: 'Text To Word',
    categoryIcon: Icons.text_fields,
  );
}
