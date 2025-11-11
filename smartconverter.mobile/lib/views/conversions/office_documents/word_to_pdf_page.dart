import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class WordToPdfPage extends StatelessWidget {
  const WordToPdfPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'office_documents_conversion',
    toolName: 'Word To PDF',
    categoryIcon: Icons.description_outlined,
  );
}
