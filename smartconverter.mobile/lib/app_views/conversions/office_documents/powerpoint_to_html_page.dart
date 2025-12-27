import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class PowerPointToHtmlOfficePage extends StatelessWidget {
  const PowerPointToHtmlOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'PowerPoint to HTML',
      description: 'Convert PowerPoint presentations to HTML.',
      featureIcon: Icons.html_outlined,
      allowedExtensions: const ['ppt', 'pptx'],
      apiEndpoint: ApiConfig.officePowerPointToHtmlEndpoint,
      targetDirectoryGetter: FileManager.getOfficePowerPointToHtmlDirectory,
      outputExtension: '.html',
      conversionButtonLabel: 'Convert to HTML',
      successMessage: 'PowerPoint converted to HTML successfully!',
    );
  }
}
