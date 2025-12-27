import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class PdfToCsvOfficePage extends StatelessWidget {
  const PdfToCsvOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'PDF to CSV',
      description: 'Convert PDF tables to CSV format.',
      featureIcon: Icons.table_chart_outlined,
      allowedExtensions: const ['pdf'],
      apiEndpoint: ApiConfig.officePdfToCsvEndpoint,
      targetDirectoryGetter: FileManager.getOfficePdfToCsvDirectory,
      outputExtension: '.csv',
      conversionButtonLabel: 'Convert to CSV',
      successMessage: 'PDF converted to CSV successfully!',
    );
  }
}
