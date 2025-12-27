import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'image_format_conversion_page.dart';

class WebpToPamPage extends StatelessWidget {
  const WebpToPamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ImageFormatConversionPage(
      toolName: 'Convert WebP to PAM',
      sourceFormat: 'WebP',
      targetFormat: 'PAM',
      sourceExtension: 'webp',
      targetExtension: 'pam',
      apiEndpoint: ApiConfig.imageWebpToPamEndpoint,
    );
  }
}
