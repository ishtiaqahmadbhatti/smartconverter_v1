
import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'file_validator_common_page.dart';

class XsdValidatorPage extends StatelessWidget {
  const XsdValidatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FileValidatorCommonPage(
      toolName: 'Validate XSD',
      inputExtension: 'xsd',
      // No schema for XSD itself in this endpoint logic usually, 
      // or at least schemaExtension=null means disable 2nd file picker
      schemaExtension: null, 
      apiEndpoint: ApiConfig.fileValidateXsdEndpoint,
    );
  }
}
