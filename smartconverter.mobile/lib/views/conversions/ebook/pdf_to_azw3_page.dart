import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToAzw3Page extends StatelessWidget {
  const PdfToAzw3Page({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'Convert PDF to AZW3',
    categoryIcon: Icons.menu_book_outlined,
  );
}
