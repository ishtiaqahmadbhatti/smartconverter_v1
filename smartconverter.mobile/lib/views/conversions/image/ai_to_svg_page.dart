import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AiToSvgImagePage extends StatelessWidget {
  const AiToSvgImagePage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'image_conversion',
    toolName: 'Convert AI to SVG',
    categoryIcon: Icons.image_outlined,
  );
}
