import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class MobiToPdfPage extends StatelessWidget {
  const MobiToPdfPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'MOBI To PDF',
    categoryIcon: Icons.menu_book_outlined,
  );
}
