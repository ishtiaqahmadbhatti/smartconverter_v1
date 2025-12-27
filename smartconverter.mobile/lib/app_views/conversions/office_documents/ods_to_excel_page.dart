import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class OdsToExcelOfficePage extends StatelessWidget {
  const OdsToExcelOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'ODS to Excel',
      description: 'Convert ODS spreadsheets to Excel.',
      featureIcon: Icons.grid_on_outlined,
      allowedExtensions: const ['ods'],
      apiEndpoint: ApiConfig.officeOdsToExcelEndpoint,
      targetDirectoryGetter: FileManager.getOfficeOdsToExcelDirectory,
      outputExtension: '.xlsx',
      conversionButtonLabel: 'Convert to Excel',
      successMessage: 'ODS converted to Excel successfully!',
    );
  }
}
