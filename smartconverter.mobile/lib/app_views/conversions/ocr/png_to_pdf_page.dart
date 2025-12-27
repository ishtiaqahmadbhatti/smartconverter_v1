import 'package:flutter/material.dart';
import '../../../constants/api_config.dart';
import 'ocr_common_page.dart';

class OcrPngToPdfPage extends StatelessWidget {
  const OcrPngToPdfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const OcrCommonPage(
      toolName: 'OCR: Convert PNG to PDF',
      inputExtension: 'png',
      outputExtension: 'pdf',
      apiEndpoint: ApiConfig.ocrPngToPdfEndpoint,
      outputFolder: 'png-to-pdf',
    );
  }
}
