import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ExcelToXmlPage extends StatelessWidget {
  const ExcelToXmlPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'xml_conversion',
    toolName: 'Convert Excel to XML',
    categoryIcon: Icons.schema_outlined,
  );
}
