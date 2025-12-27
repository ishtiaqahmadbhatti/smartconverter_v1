import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import '../../../utils/file_manager.dart';
import 'base_office_conversion_page.dart';

class XmlToExcelOfficePage extends StatelessWidget {
  const XmlToExcelOfficePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseOfficeConversionPage(
      pageTitle: 'XML to Excel',
      description: 'Convert XML data to Excel.',
      featureIcon: Icons.grid_on_outlined,
      allowedExtensions: const ['xml'],
      apiEndpoint: ApiConfig.officeXmlToExcelEndpoint,
      targetDirectoryGetter: FileManager.getOfficeXmlToExcelDirectory,
      outputExtension: '.xlsx',
      conversionButtonLabel: 'Convert to Excel',
      successMessage: 'XML converted to Excel successfully!',
    );
  }
}
