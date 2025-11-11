import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class EpubToPdfPage extends StatelessWidget {
  const EpubToPdfPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'EPUB To PDF',
    categoryIcon: Icons.menu_book_outlined,
  );
}
