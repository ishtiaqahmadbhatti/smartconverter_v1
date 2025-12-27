import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class CsvToExcelOfficePage extends StatelessWidget {
  const CsvToExcelOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'CSV to Excel',
      description: 'Convert CSV files to Excel.',
      featureIcon: Icons.table_chart_outlined,
      allowedExtensions: const ['csv'],
      apiEndpoint: ApiConfig.officeCsvToExcelEndpoint,
      targetDirectoryGetter: FileManager.getOfficeCsvToExcelDirectory,
      outputExtension: '.xlsx',
      conversionButtonLabel: 'Convert to Excel',
      successMessage: 'CSV converted to Excel successfully!',
    );
  }
}
