
import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'file_validator_common_page.dart';

class XmlValidatorPage extends StatelessWidget {
  const XmlValidatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FileValidatorCommonPage(
      toolName: 'Validate XML',
      inputExtension: 'xml',
      schemaExtension: 'xsd', 
      apiEndpoint: ApiConfig.fileValidateXmlEndpoint,
    );
  }
}
