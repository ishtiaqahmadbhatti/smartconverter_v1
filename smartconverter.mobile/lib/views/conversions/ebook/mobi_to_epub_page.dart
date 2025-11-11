import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class MobiToEpubPage extends StatelessWidget {
  const MobiToEpubPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'Convert MOBI to ePUB',
    categoryIcon: Icons.menu_book_outlined,
  );
}
