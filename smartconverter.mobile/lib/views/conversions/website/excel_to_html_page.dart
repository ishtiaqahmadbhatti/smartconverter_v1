import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ExcelToHtmlWebPage extends StatelessWidget {
  const ExcelToHtmlWebPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'website_conversion',
    toolName: 'Convert Excel to HTML',
    categoryIcon: Icons.public_outlined,
  );
}
