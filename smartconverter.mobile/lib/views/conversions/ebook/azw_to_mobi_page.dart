import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AzwToMobiPage extends StatelessWidget {
  const AzwToMobiPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'Convert AZW to MOBI',
    categoryIcon: Icons.menu_book_outlined,
  );
}
