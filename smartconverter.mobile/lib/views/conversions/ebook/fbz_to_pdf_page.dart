import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class FbzToPdfPage extends StatelessWidget {
  const FbzToPdfPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'Convert FBZ to PDF',
    categoryIcon: Icons.menu_book_outlined,
  );
}
