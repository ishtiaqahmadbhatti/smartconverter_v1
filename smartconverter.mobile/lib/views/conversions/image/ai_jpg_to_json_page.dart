import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AiJpgToJsonImagePage extends StatelessWidget {
  const AiJpgToJsonImagePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'AI: Convert JPG to JSON',
    categoryIcon: Icons.image_outlined,
  );
}
