import 'package:flutter/material.dart';

import '../image/pdf_to_svg_page.dart';

class PdfToSvgPage extends StatelessWidget {
  const PdfToSvgPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const PdfToSvgImagePage(useImageCategoryStorage: false);
}

