import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToAzwPage extends StatelessWidget {
  const PdfToAzwPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'PDF To AZW',
    categoryIcon: Icons.menu_book_outlined,
  );
}
