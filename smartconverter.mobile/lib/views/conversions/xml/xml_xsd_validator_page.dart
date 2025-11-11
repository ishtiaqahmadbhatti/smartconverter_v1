import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class XmlXsdValidatorPage extends StatelessWidget {
  const XmlXsdValidatorPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'xml_conversion',
    toolName: 'XML/XSD Validator',
    categoryIcon: Icons.schema_outlined,
  );
}
