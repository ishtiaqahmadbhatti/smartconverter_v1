import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class JpegToPgmPage extends StatelessWidget {
  const JpegToPgmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert JPEG to PGM',
      sourceFormat: 'JPEG',
      targetFormat: 'PGM',
      sourceExtension: 'jpg',
      targetExtension: 'pgm',
      apiEndpoint: ApiConfig.imageJpegToPgmEndpoint,
    );
  }
}
