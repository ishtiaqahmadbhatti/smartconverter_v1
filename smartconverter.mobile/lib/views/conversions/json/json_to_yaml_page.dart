import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class JsonToYamlPage extends StatelessWidget {
  const JsonToYamlPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'json_conversion',
    toolName: 'Convert JSON to YAML',
    categoryIcon: Icons.data_object,
  );
}
