import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class TextFormatConversionPage extends StatelessWidget {
  const TextFormatConversionPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'text_conversion',
    toolName: 'Text Format Conversion',
    categoryIcon: Icons.text_fields,
  );
}
