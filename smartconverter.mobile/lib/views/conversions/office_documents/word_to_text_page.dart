import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class WordToTextPage extends StatelessWidget {
  const WordToTextPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'office_documents_conversion',
    toolName: 'Word To Text',
    categoryIcon: Icons.description_outlined,
  );
}
