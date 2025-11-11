import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class XmlValidationPage extends StatelessWidget {
  const XmlValidationPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'xml_conversion',
    toolName: 'XML Validation',
    categoryIcon: Icons.schema_outlined,
  );
}
