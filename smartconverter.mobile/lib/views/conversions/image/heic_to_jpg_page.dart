import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'image_format_conversion_page.dart';

class HeicToJpgPage extends StatelessWidget {
  const HeicToJpgPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert HEIC to JPG',
      sourceFormat: 'HEIC',
      targetFormat: 'JPG',
      sourceExtension: 'heic',
      targetExtension: 'jpg',
      apiEndpoint: ApiConfig.imageHeicToJpgEndpoint,
    );
  }
}
