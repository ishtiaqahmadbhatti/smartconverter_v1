
import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'file_validator_common_page.dart';

class JsonSchemaInfoPage extends StatelessWidget {
  const JsonSchemaInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FileValidatorCommonPage(
      toolName: 'Get JSON Schema Info',
      inputExtension: 'json',
      schemaExtension: null,
      apiEndpoint: ApiConfig.fileJsonSchemaInfoEndpoint,
    );
  }
}
