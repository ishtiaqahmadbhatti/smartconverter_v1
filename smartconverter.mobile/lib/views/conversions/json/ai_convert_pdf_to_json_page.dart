import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class AiConvertPdfToJsonPage extends StatelessWidget {
  const AiConvertPdfToJsonPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'json_conversion',
    toolName: 'AI: Convert PDF to JSON',
    categoryIcon: Icons.data_object,
  );
}
