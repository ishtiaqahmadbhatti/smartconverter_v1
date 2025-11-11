import 'package:flutter/material.dart';
import '../../tool_action_page.dart';

class CsvToExcelPage extends StatelessWidget {
  const CsvToExcelPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'CSV To Excel',
    categoryIcon: Icons.table_chart_outlined,
  );
}

class CsvToJsonPage extends StatelessWidget {
  const CsvToJsonPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'CSV To JSON',
    categoryIcon: Icons.table_chart_outlined,
  );
}

class CsvToXmlPage extends StatelessWidget {
  const CsvToXmlPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'CSV To XML',
    categoryIcon: Icons.table_chart_outlined,
  );
}

class CsvValidationPage extends StatelessWidget {
  const CsvValidationPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'CSV Validation',
    categoryIcon: Icons.table_chart_outlined,
  );
}

class CsvFormatterPage extends StatelessWidget {
  const CsvFormatterPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'CSV Formatter',
    categoryIcon: Icons.table_chart_outlined,
  );
}
