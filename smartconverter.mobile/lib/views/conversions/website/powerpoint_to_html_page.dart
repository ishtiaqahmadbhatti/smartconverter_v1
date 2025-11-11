import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PowerPointToHtmlWebPage extends StatelessWidget {
  const PowerPointToHtmlWebPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'website_conversion',
    toolName: 'Convert PowerPoint to HTML',
    categoryIcon: Icons.public_outlined,
  );
}
