import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class PngToPpmPage extends StatelessWidget {
  const PngToPpmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert PNG to PPM',
      sourceFormat: 'PNG',
      targetFormat: 'PPM',
      sourceExtension: 'png',
      targetExtension: 'ppm',
      apiEndpoint: ApiConfig.imagePngToPpmEndpoint,
    );
  }
}
