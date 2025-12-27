import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class ExcelToPdfOfficePage extends StatelessWidget {
  const ExcelToPdfOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'Excel to PDF',
      description: 'Convert Excel spreadsheets to PDF.',
      featureIcon: Icons.picture_as_pdf_outlined,
      allowedExtensions: const ['xls', 'xlsx'],
      apiEndpoint: ApiConfig.officeExcelToPdfEndpoint,
      targetDirectoryGetter: FileManager.getOfficeExcelToPdfDirectory,
      outputExtension: '.pdf',
      conversionButtonLabel: 'Convert to PDF',
      successMessage: 'Excel converted to PDF successfully!',
    );
  }
}
