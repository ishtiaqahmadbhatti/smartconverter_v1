import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class JsonValidationPage extends StatelessWidget {
  const JsonValidationPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'json_conversion',
    toolName: 'JSON Validation',
    categoryIcon: Icons.data_object,
  );
}
