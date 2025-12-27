import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class UrlToImagePage extends StatelessWidget {
  const UrlToImagePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'website_conversion',
    toolName: 'URL To Image',
    categoryIcon: Icons.public_outlined,
  );
}
