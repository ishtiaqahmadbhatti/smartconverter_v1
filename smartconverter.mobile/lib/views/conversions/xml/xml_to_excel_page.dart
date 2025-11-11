import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class XmlToExcelPage extends StatelessWidget {
  const XmlToExcelPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'xml_conversion',
    toolName: 'Convert XML to Excel',
    categoryIcon: Icons.schema_outlined,
  );
}
