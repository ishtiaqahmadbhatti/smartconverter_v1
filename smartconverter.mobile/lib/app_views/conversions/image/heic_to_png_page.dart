import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class HeicToPngPage extends StatelessWidget {
  const HeicToPngPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert HEIC to PNG',
      sourceFormat: 'HEIC',
      targetFormat: 'PNG',
      sourceExtension: 'heic',
      targetExtension: 'png',
      apiEndpoint: ApiConfig.imageHeicToPngEndpoint,
    );
  }
}
