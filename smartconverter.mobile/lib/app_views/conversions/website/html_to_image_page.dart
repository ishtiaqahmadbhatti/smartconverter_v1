import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class HtmlToImagePage extends StatelessWidget {
  const HtmlToImagePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'website_conversion',
    toolName: 'HTML To Image',
    categoryIcon: Icons.public_outlined,
  );
}
