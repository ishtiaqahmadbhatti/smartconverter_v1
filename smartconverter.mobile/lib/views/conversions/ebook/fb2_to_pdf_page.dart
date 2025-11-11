import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class Fb2ToPdfPage extends StatelessWidget {
  const Fb2ToPdfPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'Convert FB2 to PDF',
    categoryIcon: Icons.menu_book_outlined,
  );
}
