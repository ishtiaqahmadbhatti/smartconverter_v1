import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class PngToPdfImagePage extends StatelessWidget {
  const PngToPdfImagePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'Convert PNG to PDF',
    categoryIcon: Icons.image_outlined,
  );
}
