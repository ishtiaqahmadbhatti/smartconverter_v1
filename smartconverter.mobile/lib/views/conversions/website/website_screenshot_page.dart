import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class WebsiteScreenshotPage extends StatelessWidget {
  const WebsiteScreenshotPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'website_conversion',
    toolName: 'Website Screenshot',
    categoryIcon: Icons.public_outlined,
  );
}
