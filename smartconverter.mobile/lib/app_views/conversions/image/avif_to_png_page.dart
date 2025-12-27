import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'image_format_conversion_page.dart';

class AvifToPngPage extends StatelessWidget {
  const AvifToPngPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert AVIF to PNG',
      sourceFormat: 'AVIF',
      targetFormat: 'PNG',
      sourceExtension: 'avif',
      targetExtension: 'png',
      apiEndpoint: ApiConfig.imageAvifToPngEndpoint,
    );
  }
}
