import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class HtmlToPdfWebPage extends StatelessWidget {
  const HtmlToPdfWebPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'website_conversion',
    toolName: 'HTML To PDF',
    categoryIcon: Icons.public_outlined,
  );
}
