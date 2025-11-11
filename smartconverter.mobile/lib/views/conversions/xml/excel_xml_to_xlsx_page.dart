import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class ExcelXmlToXlsxPage extends StatelessWidget {
  const ExcelXmlToXlsxPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'xml_conversion',
    toolName: 'Convert Excel XML to Excel XLSX',
    categoryIcon: Icons.schema_outlined,
  );
}
