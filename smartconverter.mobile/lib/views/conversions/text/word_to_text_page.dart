import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class WordToTextTextPage extends StatelessWidget {
  const WordToTextTextPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'text_conversion',
    toolName: 'Word To Text',
    categoryIcon: Icons.text_fields,
  );
}
