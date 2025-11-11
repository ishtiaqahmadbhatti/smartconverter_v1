import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class XmlFormatterPage extends StatelessWidget {
  const XmlFormatterPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'xml_conversion',
    toolName: 'XML Formatter',
    categoryIcon: Icons.schema_outlined,
  );
}
