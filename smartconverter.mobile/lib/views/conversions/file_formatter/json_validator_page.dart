import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class JsonValidatorPage extends StatelessWidget {
  const JsonValidatorPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'file_formatter',
    toolName: 'JSON Validator',
    categoryIcon: Icons.format_align_left,
  );
}
