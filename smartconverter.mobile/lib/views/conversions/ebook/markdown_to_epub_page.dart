import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class MarkdownToEpubPage extends StatelessWidget {
  const MarkdownToEpubPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'Convert Markdown to ePUB',
    categoryIcon: Icons.menu_book_outlined,
  );
}
