import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class PdfToWordOfficePage extends StatelessWidget {
  const PdfToWordOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'PDF to Word',
      description: 'Convert PDF documents to editable Word files.',
      featureIcon: Icons.description_outlined,
      allowedExtensions: const ['pdf'],
      apiEndpoint: ApiConfig.officePdfToWordEndpoint,
      targetDirectoryGetter: FileManager.getOfficePdfToWordDirectory,
      outputExtension: '.docx',
      conversionButtonLabel: 'Convert to Word',
      successMessage: 'PDF converted to Word successfully!',
    );
  }
}
