import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'image_format_conversion_page.dart';

class JpegToPpmPage extends StatelessWidget {
  const JpegToPpmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert JPEG to PPM',
      sourceFormat: 'JPEG',
      targetFormat: 'PPM',
      sourceExtension: 'jpg',
      targetExtension: 'ppm',
      apiEndpoint: ApiConfig.imageJpegToPpmEndpoint,
    );
  }
}
