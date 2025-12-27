
import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'file_validator_common_page.dart';

class JsonValidationToolPage extends StatelessWidget {
  const JsonValidationToolPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FileValidatorCommonPage(
      toolName: 'Validate JSON',
      inputExtension: 'json',
      schemaExtension: 'json', // Optional schema file also JSON usually
      apiEndpoint: ApiConfig.fileValidateJsonEndpoint,
    );
  }
}
