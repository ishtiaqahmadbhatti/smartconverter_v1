import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class JpgToPdfImagePage extends StatelessWidget {
  const JpgToPdfImagePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'Convert JPG to PDF',
    categoryIcon: Icons.image_outlined,
  );
}
