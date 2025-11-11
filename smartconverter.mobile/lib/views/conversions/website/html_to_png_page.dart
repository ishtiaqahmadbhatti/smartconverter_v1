import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class HtmlToPngWebPage extends StatelessWidget {
  const HtmlToPngWebPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'website_conversion',
    toolName: 'Convert HTML to PNG',
    categoryIcon: Icons.public_outlined,
  );
}
