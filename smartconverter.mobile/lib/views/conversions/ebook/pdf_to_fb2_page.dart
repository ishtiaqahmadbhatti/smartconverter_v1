import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PdfToFb2Page extends StatelessWidget {
  const PdfToFb2Page({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'Convert PDF to FB2',
    categoryIcon: Icons.menu_book_outlined,
  );
}
