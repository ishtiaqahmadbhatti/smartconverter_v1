import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AiPngToJsonImagePage extends StatelessWidget {
  const AiPngToJsonImagePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'AI: Convert PNG to JSON',
    categoryIcon: Icons.image_outlined,
  );
}
