import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class PngToAvifPage extends StatelessWidget {
  const PngToAvifPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert PNG to AVIF',
      sourceFormat: 'PNG',
      targetFormat: 'AVIF',
      sourceExtension: 'png',
      targetExtension: 'avif',
      apiEndpoint: ApiConfig.imagePngToAvifEndpoint,
    );
  }
}
