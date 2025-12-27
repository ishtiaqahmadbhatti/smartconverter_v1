import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import '../../../app_utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class BsonToExcelOfficePage extends StatelessWidget {
  const BsonToExcelOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'BSON to Excel',
      description: 'Convert BSON data to Excel.',
      featureIcon: Icons.data_usage_outlined,
      allowedExtensions: const ['bson'],
      apiEndpoint: ApiConfig.officeBsonToExcelEndpoint,
      targetDirectoryGetter: FileManager.getOfficeBsonToExcelDirectory,
      outputExtension: '.xlsx',
      conversionButtonLabel: 'Convert to Excel',
      successMessage: 'BSON converted to Excel successfully!',
    );
  }
}
