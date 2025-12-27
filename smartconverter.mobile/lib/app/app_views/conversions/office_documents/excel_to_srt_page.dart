import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class ExcelToSrtOfficePage extends StatelessWidget {
  const ExcelToSrtOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'Excel to SRT',
      description: 'Convert Excel spreadsheets to SRT subtitles.',
      featureIcon: Icons.subtitles_outlined,
      allowedExtensions: const ['xls', 'xlsx'],
      apiEndpoint: ApiConfig.officeExcelToSrtEndpoint,
      targetDirectoryGetter: FileManager.getOfficeExcelToSrtDirectory,
      outputExtension: '.srt',
      conversionButtonLabel: 'Convert to SRT',
      successMessage: 'Excel converted to SRT successfully!',
    );
  }
}
