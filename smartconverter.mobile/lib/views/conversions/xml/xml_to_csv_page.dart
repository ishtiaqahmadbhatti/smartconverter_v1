import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class XmlToCsvPage extends StatelessWidget {
  const XmlToCsvPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'xml_conversion',
    toolName: 'XML To CSV',
    categoryIcon: Icons.schema_outlined,
  );
}
