import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class EpubToAzwPage extends StatelessWidget {
  const EpubToAzwPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'Convert ePUB to AZW',
    categoryIcon: Icons.menu_book_outlined,
  );
}
