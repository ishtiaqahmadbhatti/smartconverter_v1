import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class OdsToCsvOfficePage extends StatelessWidget {
  const OdsToCsvOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'ODS to CSV',
      description: 'Convert ODS spreadsheets to CSV.',
      featureIcon: Icons.table_chart_outlined,
      allowedExtensions: const ['ods'],
      apiEndpoint: ApiConfig.officeOdsToCsvEndpoint,
      targetDirectoryGetter: FileManager.getOfficeOdsToCsvDirectory,
      outputExtension: '.csv',
      conversionButtonLabel: 'Convert to CSV',
      successMessage: 'ODS converted to CSV successfully!',
    );
  }
}
