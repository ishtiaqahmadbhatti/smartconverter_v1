import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToEpubPage extends StatelessWidget {
  const PdfToEpubPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'PDF To EPUB',
    categoryIcon: Icons.menu_book_outlined,
  );
}
