import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class XlsxToSrtOfficePage extends StatelessWidget {
  const XlsxToSrtOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'XLSX to SRT',
      description: 'Convert XLSX spreadsheets to SRT subtitles.',
      featureIcon: Icons.subtitles_outlined,
      allowedExtensions: const ['xlsx'],
      apiEndpoint: ApiConfig.officeXlsxToSrtEndpoint,
      targetDirectoryGetter: FileManager.getOfficeXlsxToSrtDirectory,
      outputExtension: '.srt',
      conversionButtonLabel: 'Convert to SRT',
      successMessage: 'XLSX converted to SRT successfully!',
    );
  }
}
