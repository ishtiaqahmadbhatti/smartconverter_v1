import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class SrtToXlsxOfficePage extends StatelessWidget {
  const SrtToXlsxOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'SRT to XLSX',
      description: 'Convert SRT subtitles to XLSX.',
      featureIcon: Icons.subtitles_outlined,
      allowedExtensions: const ['srt'],
      apiEndpoint: ApiConfig.officeSrtToXlsxEndpoint,
      targetDirectoryGetter: FileManager.getOfficeSrtToXlsxDirectory,
      outputExtension: '.xlsx',
      conversionButtonLabel: 'Convert to XLSX',
      successMessage: 'SRT converted to XLSX successfully!',
    );
  }
}
