import '../../../app_modules/imports_module.dart';

class CsvValidationPage extends StatelessWidget {
  const CsvValidationPage({super.key});
  @override
  Widget build(BuildContext context) => const ToolActionPage(
    categoryId: 'csv_conversion',
    toolName: 'CSV Validation',
    categoryIcon: Icons.table_chart_outlined,
  );
}
