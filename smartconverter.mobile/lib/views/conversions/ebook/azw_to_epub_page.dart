import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AzwToEpubPage extends StatelessWidget {
  const AzwToEpubPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'Convert AZW to ePUB',
    categoryIcon: Icons.menu_book_outlined,
  );
}
