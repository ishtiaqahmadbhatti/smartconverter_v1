import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class WordToHtmlOfficePage extends StatelessWidget {
  const WordToHtmlOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'Word to HTML',
      description: 'Convert Word documents to HTML.',
      featureIcon: Icons.html_outlined,
      allowedExtensions: const ['doc', 'docx'],
      apiEndpoint: ApiConfig.officeWordToHtmlEndpoint,
      targetDirectoryGetter: FileManager.getOfficeWordToHtmlDirectory,
      outputExtension: '.html',
      conversionButtonLabel: 'Convert to HTML',
      successMessage: 'Word converted to HTML successfully!',
    );
  }
}
