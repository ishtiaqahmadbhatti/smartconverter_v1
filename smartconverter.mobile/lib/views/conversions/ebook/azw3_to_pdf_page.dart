import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class Azw3ToPdfPage extends StatelessWidget {
  const Azw3ToPdfPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'Convert AZW3 to PDF',
    categoryIcon: Icons.menu_book_outlined,
  );
}
