import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class JsonToExcelOfficePage extends StatelessWidget {
  const JsonToExcelOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'JSON to Excel',
      description: 'Convert JSON data to Excel.',
      featureIcon: Icons.data_object_outlined,
      allowedExtensions: const ['json'],
      apiEndpoint: ApiConfig.officeJsonToExcelEndpoint,
      targetDirectoryGetter: FileManager.getOfficeJsonToExcelDirectory,
      outputExtension: '.xlsx',
      conversionButtonLabel: 'Convert to Excel',
      successMessage: 'JSON converted to Excel successfully!',
    );
  }
}
