import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class PngToJpgPage extends StatelessWidget {
  const PngToJpgPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert PNG to JPG',
      sourceFormat: 'PNG',
      targetFormat: 'JPG',
      sourceExtension: 'png',
      targetExtension: 'jpg',
      apiEndpoint: ApiConfig.imagePngToJpgEndpoint,
    );
  }
}
