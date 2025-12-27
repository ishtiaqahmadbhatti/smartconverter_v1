import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class XlsToSrtOfficePage extends StatelessWidget {
  const XlsToSrtOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'XLS to SRT',
      description: 'Convert XLS spreadsheets to SRT subtitles.',
      featureIcon: Icons.subtitles_outlined,
      allowedExtensions: const ['xls'],
      apiEndpoint: ApiConfig.officeXlsToSrtEndpoint,
      targetDirectoryGetter: FileManager.getOfficeXlsToSrtDirectory,
      outputExtension: '.srt',
      conversionButtonLabel: 'Convert to SRT',
      successMessage: 'XLS converted to SRT successfully!',
    );
  }
}
