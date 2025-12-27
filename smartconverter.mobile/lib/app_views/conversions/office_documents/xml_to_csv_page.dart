import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class XmlToCsvOfficePage extends StatelessWidget {
  const XmlToCsvOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'XML to CSV',
      description: 'Convert XML data to CSV.',
      featureIcon: Icons.table_chart_outlined,
      allowedExtensions: const ['xml'],
      apiEndpoint: ApiConfig.officeXmlToCsvEndpoint,
      targetDirectoryGetter: FileManager.getOfficeXmlToCsvDirectory,
      outputExtension: '.csv',
      conversionButtonLabel: 'Convert to CSV',
      successMessage: 'XML converted to CSV successfully!',
    );
  }
}
