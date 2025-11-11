import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class CsvToXmlFromXmlCategoryPage extends StatelessWidget {
  const CsvToXmlFromXmlCategoryPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'xml_conversion',
    toolName: 'Convert CSV to XML',
    categoryIcon: Icons.schema_outlined,
  );
}
