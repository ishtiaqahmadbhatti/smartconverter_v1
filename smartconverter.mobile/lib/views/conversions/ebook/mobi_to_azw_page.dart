import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class MobiToAzwPage extends StatelessWidget {
  const MobiToAzwPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'Convert MOBI to AZW',
    categoryIcon: Icons.menu_book_outlined,
  );
}
