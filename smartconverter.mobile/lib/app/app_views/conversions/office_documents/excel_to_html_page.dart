import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class ExcelToHtmlOfficePage extends StatelessWidget {
  const ExcelToHtmlOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'Excel to HTML',
      description: 'Convert Excel spreadsheets to HTML.',
      featureIcon: Icons.html_outlined,
      allowedExtensions: const ['xls', 'xlsx'],
      apiEndpoint: ApiConfig.officeExcelToHtmlEndpoint,
      targetDirectoryGetter: FileManager.getOfficeExcelToHtmlDirectory,
      outputExtension: '.html',
      conversionButtonLabel: 'Convert to HTML',
      successMessage: 'Excel converted to HTML successfully!',
    );
  }
}
