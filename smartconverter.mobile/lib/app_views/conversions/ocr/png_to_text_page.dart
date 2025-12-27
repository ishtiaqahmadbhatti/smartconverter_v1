import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'ocr_common_page.dart';

class OcrPngToTextPage extends StatelessWidget {
  const OcrPngToTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OcrCommonPage(
      toolName: 'OCR: Convert PNG to Text',
      inputExtension: 'png',
      outputExtension: 'txt',
      apiEndpoint: ApiConfig.ocrPngToTextEndpoint,
      outputFolder: 'png-to-text',
    );
  }
}
