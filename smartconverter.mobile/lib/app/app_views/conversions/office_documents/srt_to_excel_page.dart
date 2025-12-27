import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class SrtToExcelOfficePage extends StatelessWidget {
  const SrtToExcelOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'SRT to Excel',
      description: 'Convert SRT subtitles to Excel.',
      featureIcon: Icons.subtitles_outlined,
      allowedExtensions: const ['srt'],
      apiEndpoint: ApiConfig.officeSrtToExcelEndpoint,
      targetDirectoryGetter: FileManager.getOfficeSrtToExcelDirectory,
      outputExtension: '.xlsx',
      conversionButtonLabel: 'Convert to Excel',
      successMessage: 'SRT converted to Excel successfully!',
    );
  }
}
