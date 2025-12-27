import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class WordToTextOfficePage extends StatelessWidget {
  const WordToTextOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'Word to Text',
      description: 'Extract plain text from Word documents.',
      featureIcon: Icons.text_snippet_outlined,
      allowedExtensions: const ['doc', 'docx'],
      apiEndpoint: ApiConfig.officeWordToTextEndpoint,
      targetDirectoryGetter: FileManager.getOfficeWordToTextDirectory,
      outputExtension: '.txt',
      conversionButtonLabel: 'Convert to Text',
      successMessage: 'Word converted to Text successfully!',
    );
  }
}
