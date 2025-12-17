import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class JsonObjectsToExcelOfficePage extends StatelessWidget {
  const JsonObjectsToExcelOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'JSON Objects to Excel',
      description: 'Convert list of JSON objects to Excel.',
      featureIcon: Icons.list_alt_outlined,
      allowedExtensions: const ['json'],
      apiEndpoint: ApiConfig.officeJsonObjectsToExcelEndpoint,
      targetDirectoryGetter: FileManager.getOfficeJsonObjectsToExcelDirectory,
      outputExtension: '.xlsx',
      conversionButtonLabel: 'Convert to Excel',
      successMessage: 'JSON objects converted to Excel successfully!',
    );
  }
}
