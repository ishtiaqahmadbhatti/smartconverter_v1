import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class WebsiteToJpgPage extends StatelessWidget {
  const WebsiteToJpgPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'website_conversion',
    toolName: 'Convert Website to JPG',
    categoryIcon: Icons.public_outlined,
  );
}
