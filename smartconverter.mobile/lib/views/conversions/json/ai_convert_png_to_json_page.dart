import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AiConvertPngToJsonPage extends StatelessWidget {
  const AiConvertPngToJsonPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'json_conversion',
    toolName: 'AI: Convert PNG to JSON',
    categoryIcon: Icons.data_object,
  );
}
