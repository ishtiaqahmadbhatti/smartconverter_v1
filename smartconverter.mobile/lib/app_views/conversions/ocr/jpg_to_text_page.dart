import 'package:flutter/material.dart';
import '../../../app_constants/api_config.dart';
import 'ocr_common_page.dart';

class OcrJpgToTextPage extends StatelessWidget {
  const OcrJpgToTextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OcrCommonPage(
      toolName: 'OCR: Convert JPG to Text',
      inputExtension: 'jpg',
      outputExtension: 'txt',
      apiEndpoint: ApiConfig.ocrJpgToTextEndpoint,
      outputFolder: 'jpg-to-text',
    );
  }
}
