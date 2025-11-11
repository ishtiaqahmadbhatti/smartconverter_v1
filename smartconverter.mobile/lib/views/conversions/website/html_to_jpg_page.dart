import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class HtmlToJpgWebPage extends StatelessWidget {
  const HtmlToJpgWebPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'website_conversion',
    toolName: 'Convert HTML to JPG',
    categoryIcon: Icons.public_outlined,
  );
}
