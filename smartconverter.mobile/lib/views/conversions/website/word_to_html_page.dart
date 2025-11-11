import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class WordToHtmlWebPage extends StatelessWidget {
  const WordToHtmlWebPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'website_conversion',
    toolName: 'Convert Word to HTML',
    categoryIcon: Icons.public_outlined,
  );
}
