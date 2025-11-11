import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class YamlToJsonPage extends StatelessWidget {
  const YamlToJsonPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'json_conversion',
    toolName: 'Convert YAML to JSON',
    categoryIcon: Icons.data_object,
  );
}
