import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class ExcelToJsonOfficePage extends StatelessWidget {
  const ExcelToJsonOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'Excel to JSON',
      description: 'Convert Excel spreadsheets to JSON.',
      featureIcon: Icons.data_object_outlined,
      allowedExtensions: const ['xls', 'xlsx'],
      apiEndpoint: ApiConfig.officeExcelToJsonEndpoint,
      targetDirectoryGetter: FileManager.getOfficeExcelToJsonDirectory,
      outputExtension: '.json',
      conversionButtonLabel: 'Convert to JSON',
      successMessage: 'Excel converted to JSON successfully!',
    );
  }
}
