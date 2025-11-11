import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AiConvertJpgToJsonPage extends StatelessWidget {
  const AiConvertJpgToJsonPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'json_conversion',
    toolName: 'AI: Convert JPG to JSON',
    categoryIcon: Icons.data_object,
  );
}
