import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class EpubToMobiPage extends StatelessWidget {
  const EpubToMobiPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'ebook_conversion',
    toolName: 'Convert ePUB to MOBI',
    categoryIcon: Icons.menu_book_outlined,
  );
}
