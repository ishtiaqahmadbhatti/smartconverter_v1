import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class XmlFixEscapingPage extends StatelessWidget {
  const XmlFixEscapingPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'xml_conversion',
    toolName: 'Fix XML Escaping',
    categoryIcon: Icons.schema_outlined,
  );
}
