import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class UrlToPdfPage extends StatelessWidget {
  const UrlToPdfPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'website_conversion',
    toolName: 'URL To PDF',
    categoryIcon: Icons.public_outlined,
  );
}
