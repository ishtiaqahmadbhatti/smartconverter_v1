import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class SrtToXlsOfficePage extends StatelessWidget {
  const SrtToXlsOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'SRT to XLS',
      description: 'Convert SRT subtitles to XLS.',
      featureIcon: Icons.subtitles_outlined,
      allowedExtensions: const ['srt'],
      apiEndpoint: ApiConfig.officeSrtToXlsEndpoint,
      targetDirectoryGetter: FileManager.getOfficeSrtToXlsDirectory,
      outputExtension: '.xls',
      conversionButtonLabel: 'Convert to XLS',
      successMessage: 'SRT converted to XLS successfully!',
    );
  }
}
