import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class JsonToXmlFromXmlCategoryPage extends StatelessWidget {
  const JsonToXmlFromXmlCategoryPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'xml_conversion',
    toolName: 'Convert JSON to XML',
    categoryIcon: Icons.schema_outlined,
  );
}
