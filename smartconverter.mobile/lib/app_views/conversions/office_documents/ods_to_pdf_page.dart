import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class OdsToPdfOfficePage extends StatelessWidget {
  const OdsToPdfOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'ODS to PDF',
      description: 'Convert ODS spreadsheets to PDF.',
      featureIcon: Icons.picture_as_pdf_outlined,
      allowedExtensions: const ['ods'],
      apiEndpoint: ApiConfig.officeOdsToPdfEndpoint,
      targetDirectoryGetter: FileManager.getOfficeOdsToPdfDirectory,
      outputExtension: '.pdf',
      conversionButtonLabel: 'Convert to PDF',
      successMessage: 'ODS converted to PDF successfully!',
    );
  }
}
