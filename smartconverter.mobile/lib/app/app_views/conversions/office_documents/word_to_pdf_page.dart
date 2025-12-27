import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class WordToPdfOfficePage extends StatelessWidget {
  const WordToPdfOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'Word to PDF',
      description: 'Convert Word documents to PDF.',
      featureIcon: Icons.picture_as_pdf_outlined,
      allowedExtensions: const ['doc', 'docx'],
      apiEndpoint: ApiConfig.officeWordToPdfEndpoint,
      targetDirectoryGetter: FileManager.getOfficeWordToPdfDirectory,
      outputExtension: '.pdf',
      conversionButtonLabel: 'Convert to PDF',
      successMessage: 'Word converted to PDF successfully!',
    );
  }
}
