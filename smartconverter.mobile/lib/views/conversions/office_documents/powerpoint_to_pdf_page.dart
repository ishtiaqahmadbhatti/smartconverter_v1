import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class PowerPointToPdfOfficePage extends StatelessWidget {
  const PowerPointToPdfOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'PowerPoint to PDF',
      description: 'Convert PowerPoint presentations to PDF.',
      featureIcon: Icons.picture_as_pdf_outlined,
      allowedExtensions: const ['ppt', 'pptx'],
      apiEndpoint: ApiConfig.officePowerPointToPdfEndpoint,
      targetDirectoryGetter: FileManager.getOfficePowerPointToPdfDirectory,
      outputExtension: '.pdf',
      conversionButtonLabel: 'Convert to PDF',
      successMessage: 'PowerPoint converted to PDF successfully!',
    );
  }
}
