import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToFbzPage extends StatelessWidget {
  const PdfToFbzPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'Convert PDF to FBZ',
    categoryIcon: Icons.menu_book_outlined,
  );
}
