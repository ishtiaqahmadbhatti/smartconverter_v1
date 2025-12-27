import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class ExcelToOdsOfficePage extends StatelessWidget {
  const ExcelToOdsOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'Excel to ODS',
      description: 'Convert Excel spreadsheets to ODS (OpenDocument Spreadsheet).',
      featureIcon: Icons.border_all_outlined,
      allowedExtensions: const ['xls', 'xlsx'],
      apiEndpoint: ApiConfig.officeExcelToOdsEndpoint,
      targetDirectoryGetter: FileManager.getOfficeExcelToOdsDirectory,
      outputExtension: '.ods',
      conversionButtonLabel: 'Convert to ODS',
      successMessage: 'Excel converted to ODS successfully!',
    );
  }
}
