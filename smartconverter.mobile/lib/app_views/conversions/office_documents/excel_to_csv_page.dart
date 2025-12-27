import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class ExcelToCsvOfficePage extends StatelessWidget {
  const ExcelToCsvOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'Excel to CSV',
      description: 'Convert Excel spreadsheets to CSV.',
      featureIcon: Icons.table_chart_outlined,
      allowedExtensions: const ['xls', 'xlsx'],
      apiEndpoint: ApiConfig.officeExcelToCsvEndpoint,
      targetDirectoryGetter: FileManager.getOfficeExcelToCsvDirectory,
      outputExtension: '.csv',
      conversionButtonLabel: 'Convert to CSV',
      successMessage: 'Excel converted to CSV successfully!',
    );
  }
}
