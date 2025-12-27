import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class ExcelToXpsOfficePage extends StatelessWidget {
  const ExcelToXpsOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'Excel to XPS',
      description: 'Convert Excel spreadsheets to XPS.',
      featureIcon: Icons.print_outlined,
      allowedExtensions: const ['xls', 'xlsx'],
      apiEndpoint: ApiConfig.officeExcelToXpsEndpoint,
      targetDirectoryGetter: FileManager.getOfficeExcelToXpsDirectory,
      outputExtension: '.xps',
      conversionButtonLabel: 'Convert to XPS',
      successMessage: 'Excel converted to XPS successfully!',
    );
  }
}
