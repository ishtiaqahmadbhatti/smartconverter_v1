import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class PowerPointToTextOfficePage extends StatelessWidget {
  const PowerPointToTextOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'PowerPoint to Text',
      description: 'Extract text from PowerPoint presentations.',
      featureIcon: Icons.text_snippet_outlined,
      allowedExtensions: const ['ppt', 'pptx'],
      apiEndpoint: ApiConfig.officePowerPointToTextEndpoint,
      targetDirectoryGetter: FileManager.getOfficePowerPointToTextDirectory,
      outputExtension: '.txt',
      conversionButtonLabel: 'Convert to Text',
      successMessage: 'PowerPoint converted to Text successfully!',
    );
  }
}
