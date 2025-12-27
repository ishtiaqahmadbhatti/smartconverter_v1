import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class AvifToJpegPage extends StatelessWidget {
  const AvifToJpegPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert AVIF to JPEG',
      sourceFormat: 'AVIF',
      targetFormat: 'JPEG',
      sourceExtension: 'avif',
      targetExtension: 'jpg',
      apiEndpoint: ApiConfig.imageAvifToJpegEndpoint,
    );
  }
}
