import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class PdfToExcelOfficePage extends StatelessWidget {
  const PdfToExcelOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'PDF to Excel',
      description: 'Convert PDF tables to Excel spreadsheets.',
      featureIcon: Icons.grid_on_outlined,
      allowedExtensions: const ['pdf'],
      apiEndpoint: ApiConfig.officePdfToExcelEndpoint,
      targetDirectoryGetter: FileManager.getOfficePdfToExcelDirectory,
      outputExtension: '.xlsx',
      conversionButtonLabel: 'Convert to Excel',
      successMessage: 'PDF converted to Excel successfully!',
    );
  }
}
