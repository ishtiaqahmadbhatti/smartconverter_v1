import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class JpgToAvifPage extends StatelessWidget {
  const JpgToAvifPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert JPG to AVIF',
      sourceFormat: 'JPG',
      targetFormat: 'AVIF',
      sourceExtension: 'jpg',
      targetExtension: 'avif',
      apiEndpoint: ApiConfig.imageJpgToAvifEndpoint,
    );
  }
}
