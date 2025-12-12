import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'tool_action_page.dart';
// JSON pages
import 'conversions/json/json_to_xml_page.dart';
import 'conversions/json/json_to_csv_page.dart';
import 'conversions/json/json_validation_page.dart';
import 'conversions/json/json_formatter_page.dart';
import 'conversions/json/ai_convert_pdf_to_json_page.dart';
import 'conversions/json/ai_convert_png_to_json_page.dart';
import 'conversions/json/ai_convert_jpg_to_json_page.dart';
import 'conversions/json/json_to_excel_page.dart';
import 'conversions/json/excel_to_json_page.dart';
import 'conversions/json/csv_to_json_page.dart';
import 'conversions/json/json_to_yaml_page.dart';
import 'conversions/json/json_objects_to_csv_page.dart';
import 'conversions/json/json_objects_to_excel_page.dart';
import 'conversions/json/yaml_to_json_page.dart';
import 'conversions/json/xml_to_json_page.dart' as json_xml;
// XML pages
import 'conversions/xml/xml_to_json_page.dart';
import 'conversions/xml/xml_to_csv_page.dart';
// (removed unused) xml_validation_page, xml_transform_page, xml_formatter_page
import 'conversions/xml/csv_to_xml_from_xml_category_page.dart';
import 'conversions/xml/excel_to_xml_page.dart';
import 'conversions/xml/xml_to_excel_page.dart';
import 'conversions/xml/xml_fix_escaping_page.dart';
import 'conversions/xml/excel_xml_to_xlsx_page.dart';
import 'conversions/xml/xml_xsd_validator_page.dart';
import 'conversions/xml/json_to_xml_from_xml_category_page.dart';
// CSV pages
import 'conversions/csv/csv_to_excel_page.dart';
import 'conversions/csv/csv_to_xml_page.dart';
// (removed unused) csv_validation_page, csv_formatter_page
import 'conversions/csv/ai_convert_pdf_to_csv_page.dart';
// (only needed once) import for HTML Table to CSV is already present above
import 'conversions/csv/excel_to_csv_from_csv_category_page.dart';
import 'conversions/csv/ods_to_csv_page.dart';
import 'conversions/csv/xml_to_csv_from_csv_category_page.dart';
import 'conversions/csv/pdf_to_csv_page.dart';
import 'conversions/csv/json_to_csv_from_csv_category_page.dart';
import 'conversions/csv/json_objects_to_csv_from_csv_category_page.dart';
import 'conversions/csv/bson_to_csv_page.dart';
import 'conversions/csv/srt_to_csv_page.dart';
import 'conversions/csv/csv_to_srt_page.dart';
// Office pages
import 'conversions/office_documents/word_to_pdf_page.dart';
import 'conversions/office_documents/pdf_to_word_page.dart';
import 'conversions/office_documents/excel_to_pdf_page.dart';
import 'conversions/office_documents/powerpoint_to_pdf_page.dart';
import 'conversions/office_documents/word_to_text_page.dart';
import 'conversions/office_documents/excel_to_csv_page.dart';
import 'conversions/office_documents/excel_to_ods_page.dart';
import 'conversions/office_documents/ods_to_excel_page.dart';
import 'conversions/office_documents/bson_to_excel_page.dart';
// Website pages
import 'conversions/website/website_to_pdf_page.dart';
import 'conversions/website/html_to_pdf_page.dart';
import 'conversions/website/word_to_html_page.dart';
import 'conversions/website/powerpoint_to_html_page.dart';
import 'conversions/website/markdown_to_html_page.dart';
import 'conversions/website/website_to_jpg_page.dart';
import 'conversions/website/html_to_jpg_page.dart';
import 'conversions/website/website_to_png_page.dart';
import 'conversions/website/html_to_png_page.dart';
import 'conversions/website/excel_to_html_page.dart';
import 'conversions/website/pdf_to_html_web_page.dart';
// Reuse CSV tool for HTML Table to CSV
import 'conversions/website/html_table_to_csv_page.dart';
// Video pages
import 'conversions/video/mov_to_mp4_page.dart';
import 'conversions/video/mkv_to_mp4_page.dart';
import 'conversions/video/avi_to_mp4_page.dart';
import 'conversions/video/mp4_to_mp3_page.dart';
// Audio pages
import 'conversions/audio/mp4_to_mp3_from_audio_page.dart';
import 'conversions/audio/wav_to_mp3_page.dart';
import 'conversions/audio/flac_to_mp3_page.dart';
import 'conversions/audio/mp3_to_wav_page.dart';
import 'conversions/audio/flac_to_wav_page.dart';
import 'conversions/audio/wav_to_flac_page.dart';
// Subtitle pages
import 'conversions/subtitle/ai_translate_srt_page.dart';
import 'conversions/subtitle/srt_to_csv_from_subtitle_page.dart';
import 'conversions/subtitle/srt_to_excel_page.dart';
import 'conversions/subtitle/srt_to_text_page.dart';
import 'conversions/subtitle/srt_to_vtt_page.dart';
import 'conversions/subtitle/vtt_to_text_page.dart';
import 'conversions/subtitle/vtt_to_srt_page.dart';
import 'conversions/subtitle/csv_to_srt_from_subtitle_page.dart';
import 'conversions/subtitle/excel_to_srt_page.dart';
// Text pages
import 'conversions/text/word_to_text_page.dart';
import 'conversions/text/powerpoint_to_text_page.dart';
import 'conversions/text/pdf_to_text_text_page.dart';
import 'conversions/text/srt_to_text_from_text_page.dart';
import 'conversions/text/vtt_to_text_from_text_page.dart';
// File Formatter pages
import 'conversions/file_formatter/json_formatter_tool_page.dart';
import 'conversions/file_formatter/json_validator_page.dart';
// Reuse XML validator (already imported above in XML pages section)
// eBook pages
import 'conversions/ebook/epub_to_pdf_page.dart';
import 'conversions/ebook/pdf_to_epub_page.dart';
import 'conversions/ebook/mobi_to_pdf_page.dart';
import 'conversions/ebook/pdf_to_mobi_page.dart';
import 'conversions/ebook/azw_to_pdf_page.dart';
import 'conversions/ebook/pdf_to_azw_page.dart';
import 'conversions/ebook/markdown_to_epub_page.dart';
import 'conversions/ebook/epub_to_mobi_page.dart';
import 'conversions/ebook/epub_to_azw_page.dart';
import 'conversions/ebook/mobi_to_epub_page.dart';
import 'conversions/ebook/mobi_to_azw_page.dart';
import 'conversions/ebook/azw_to_epub_page.dart';
import 'conversions/ebook/azw_to_mobi_page.dart';
import 'conversions/ebook/azw3_to_pdf_page.dart';
import 'conversions/ebook/fb2_to_pdf_page.dart';
import 'conversions/ebook/fbz_to_pdf_page.dart';
import 'conversions/ebook/pdf_to_azw3_page.dart';
import 'conversions/ebook/pdf_to_fb2_page.dart';
import 'conversions/ebook/pdf_to_fbz_page.dart';
// Image pages
import 'conversions/image/ai_png_to_json_page.dart';
// PDF pages
import 'conversions/pdf/ai_pdf_to_json_page.dart';
import 'conversions/pdf/ai_pdf_to_markdown_page.dart';
import 'conversions/pdf/ai_pdf_to_csv_page.dart';
import 'conversions/pdf/ai_pdf_to_excel_page.dart';
import 'conversions/pdf/pdf_to_excel_page.dart';
import 'conversions/pdf/pdf_to_jpg_page.dart';
import 'conversions/pdf/pdf_to_png_page.dart';
import 'conversions/pdf/pdf_to_tiff_page.dart';
import 'conversions/pdf/pdf_to_svg_page.dart';
import 'conversions/pdf/pdf_to_text_page.dart';
import 'conversions/pdf/pdf_to_word_page.dart';
import 'conversions/pdf/pdf_to_html_page.dart';
import 'conversions/pdf/markdown_to_pdf_page.dart';
import 'conversions/pdf/jpg_to_pdf_page.dart';
import 'conversions/pdf/png_to_pdf_page.dart';
import 'conversions/pdf/merge_pdf_page.dart';
import 'conversions/pdf/oxps_to_pdf_page.dart';
import 'conversions/pdf/excel_to_xps_page.dart';
import 'conversions/pdf/ods_to_pdf_page.dart';
import 'conversions/pdf/pdf_split_page.dart';
import 'conversions/pdf/pdf_compress_page.dart';
import 'conversions/pdf/remove_pages_page.dart';
import 'conversions/pdf/extract_pages_page.dart';
import 'conversions/pdf/rotate_pdf_page.dart';
import 'conversions/pdf/watermark_pdf_page.dart';
import 'conversions/pdf/add_page_numbers_page.dart';
import 'conversions/pdf/crop_pdf_page.dart';
import 'conversions/pdf/protect_pdf_page.dart';
import 'conversions/pdf/unlock_pdf_page.dart';
import 'conversions/pdf/repair_pdf_page.dart';
import 'conversions/pdf/compare_pdfs_page.dart';
import 'conversions/pdf/pdf_metadata_page.dart';
import 'conversions/image/ai_jpg_to_json_page.dart';
import 'conversions/image/pdf_to_jpg_page.dart';
import 'conversions/image/pdf_to_png_page.dart';
import 'conversions/image/pdf_to_tiff_page.dart';
import 'conversions/image/pdf_to_svg_page.dart';
import 'conversions/image/ai_to_svg_page.dart';
// Reuse website converters for site/html to images (already imported above)
// OCR pages
import 'conversions/ocr/png_to_text_page.dart';
import 'conversions/ocr/jpg_to_text_page.dart';
import 'conversions/ocr/png_to_pdf_page.dart';
import 'conversions/ocr/jpg_to_pdf_page.dart';
import 'conversions/ocr/pdf_to_text_page.dart';
import 'conversions/ocr/pdf_image_to_pdf_text_page.dart';

class CategoryToolsPage extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<String> tools;

  const CategoryToolsPage({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.tools,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildDescription(),
                const SizedBox(height: 16),
                _buildToolsList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.25),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.textPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.build_outlined,
                  size: 14,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${tools.length}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        description,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildToolsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'API Tools',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: tools.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final toolName = tools[index];
            void handleTap() {
              final page = _resolveToolPage(context, id, toolName, icon);
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => page,
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: handleTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.25),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(icon, size: 18, color: AppColors.primaryBlue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          toolName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: handleTap,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _resolveToolPage(
    BuildContext context,
    String categoryId,
    String toolName,
    IconData categoryIcon,
  ) {
    // JSON category mappings
    if (categoryId == 'json_conversion') {
      switch (toolName) {
        case 'AI: Convert PDF to JSON':
          return const AiConvertPdfToJsonPage();
        case 'AI: Convert PNG to JSON':
          return const AiConvertPngToJsonPage();
        case 'AI: Convert JPG to JSON':
          return const AiConvertJpgToJsonPage();
        case 'Convert XML to JSON':
          return const json_xml.XmlToJsonPage();
        case 'JSON Formatter':
          return const JsonFormatterPage();
        case 'JSON Validator':
          return const JsonValidationPage();
        case 'Convert JSON to XML':
          return const JsonToXmlPage();
        case 'Convert JSON to CSV':
          return const JsonToCsvPage();
        case 'Convert JSON to Excel':
          return const JsonToExcelPage();
        case 'Convert Excel to JSON':
          return const ExcelToJsonPage();
        case 'Convert CSV to JSON':
          return const CsvToJsonPage();
        case 'Convert JSON to YAML':
          return const JsonToYamlPage();
        case 'Convert JSON objects to CSV':
          return const JsonObjectsToCsvPage();
        case 'Convert JSON objects to Excel':
          return const JsonObjectsToExcelPage();
        case 'Convert YAML to JSON':
          return const YamlToJsonPage();
      }
    }

    // XML category mappings
    if (categoryId == 'xml_conversion') {
      switch (toolName) {
        case 'Convert CSV to XML':
          return const CsvToXmlFromXmlCategoryPage();
        case 'Convert Excel to XML':
          return const ExcelToXmlPage();
        case 'Convert XML to JSON':
          return const XmlToJsonPage();
        case 'Convert XML to CSV':
          return const XmlToCsvPage();
        case 'Convert XML to Excel':
          return const XmlToExcelPage();
        case 'Fix XML Escaping':
          return const XmlFixEscapingPage();
        case 'Convert Excel XML to Excel XLSX':
          return const ExcelXmlToXlsxPage();
        case 'XML/XSD Validator':
          return const XmlXsdValidatorPage();
        case 'Convert JSON to XML':
          return const JsonToXmlFromXmlCategoryPage();
      }
    }

    if (categoryId == 'csv_conversion') {
      switch (toolName) {
        case 'AI: Convert PDF to CSV':
          return const AiConvertPdfToCsvPage();
        case 'Convert HTML Table to CSV':
          return const HtmlTableToCsvPage();
        case 'Convert Excel to CSV':
          return const ExcelToCsvFromCsvCategoryPage();
        case 'Convert OpenOffice Calc ODS to CSV':
          return const OdsToCsvPage();
        case 'Convert CSV to Excel':
          return const CsvToExcelPage();
        case 'Convert CSV to XML':
          return const CsvToXmlPage();
        case 'Convert XML to CSV':
          return const XmlToCsvFromCsvCategoryPage();
        case 'Convert PDF to CSV':
          return const PdfToCsvPage();
        case 'Convert JSON to CSV':
          return const JsonToCsvFromCsvCategoryPage();
        case 'Convert CSV to JSON':
          return const CsvToJsonPage();
        case 'Convert JSON objects to CSV':
          return const JsonObjectsToCsvFromCsvCategoryPage();
        case 'Convert BSON to CSV':
          return const BsonToCsvPage();
        case 'Convert SRT to CSV':
          return const SrtToCsvPage();
        case 'Convert CSV to SRT':
          return const CsvToSrtPage();
      }
    }

    if (categoryId == 'office_documents_conversion') {
      switch (toolName) {
        case 'AI: Convert PDF to CSV':
          return const AiConvertPdfToCsvPage();
        case 'AI: Convert PDF to Excel':
          return const AiPdfToExcelPage();
        case 'Convert Word to PDF':
          return const WordToPdfPage();
        case 'Convert Word to HTML':
          return const WordToHtmlPage();
        case 'Convert PowerPoint to PDF':
          return const PowerPointToPdfPage();
        case 'Convert PowerPoint to HTML':
          return const PowerPointToHtmlPage();
        case 'Convert OXPS to PDF':
          return const OxpsToPdfPage();
        case 'Convert Word to Text':
          return const WordToTextPage();
        case 'Convert PowerPoint to Text':
          return const PowerPointToTextPage();
        case 'Convert Excel to PDF':
          return const ExcelToPdfPage();
        case 'Convert Excel to XPS':
          return const ExcelToXpsPage();
        case 'Convert Excel to HTML':
          return const ExcelToHtmlWebPage();
        case 'Convert Excel to CSV':
          return const ExcelToCsvPage();
        case 'Convert Excel to OpenOffice Calc ODS':
          return const ExcelToOdsPage();
        case 'Convert OpenOffice Calc ODS to CSV':
          return const OdsToCsvPage();
        case 'Convert OpenOffice Calc ODS to PDF':
          return const OdsToPdfFromPdfCategoryPage();
        case 'Convert OpenOffice Calc ODS to Excel':
          return const OdsToExcelPage();
        case 'Convert CSV to Excel':
          return const CsvToExcelPage();
        case 'Convert Excel to XML':
          return const ExcelToXmlPage();
        case 'Convert XML to CSV':
          return const XmlToCsvPage();
        case 'Convert XML to Excel':
          return const XmlToExcelPage();
        case 'Convert Excel XML to Excel XLSX':
          return const ExcelXmlToXlsxPage();
        case 'Convert PDF to CSV':
          return const PdfToCsvPage();
        case 'Convert PDF to Excel':
          return const PdfToExcelPage();
        case 'Convert PDF to Word':
          return const PdfToWordOfficePage();
        case 'Convert JSON to Excel':
          return const JsonToExcelPage();
        case 'Convert Excel to JSON':
          return const ExcelToJsonPage();
        case 'Convert JSON objects to Excel':
          return const JsonObjectsToExcelPage();
        case 'Convert BSON to Excel':
          return const BsonToExcelPage();
        case 'Convert SRT to Excel':
          return const SrtToExcelPage();
        case 'Convert Excel to SRT':
          return const ExcelToSrtPage();
      }
    }

    if (categoryId == 'pdf_conversion') {
      switch (toolName) {
        case 'Merge PDF':
          return const MergePdfPage();
        case 'Split PDF':
          return const PdfSplitPage();
        case 'Compress PDF':
          return const PdfCompressPage();
        case 'Remove Pages':
          return const RemovePagesPage();
        case 'Extract Pages':
          return const ExtractPagesPage();
        case 'Rotate PDF':
          return const RotatePdfPage();
        case 'Add Page Numbers':
          return const AddPageNumbersPage();
        case 'Crop PDF':
          return const CropPdfPage();
        case 'Protect PDF':
          return const ProtectPdfPage();
        case 'Unlock PDF':
          return const UnlockPdfPage();
        case 'Repair PDF':
          return const RepairPdfPage();
        case 'Compare PDFs':
          return const ComparePdfsPage();
        case 'Get PDF Metadata':
          return const PdfMetadataPage();
        case 'Add Watermark':
          return const WatermarkPdfPage();
        case 'AI: Convert PDF to JSON':
          return AiPdfToJsonPage(categoryId: categoryId);
        case 'AI: Convert PDF to Markdown':
          return const AiPdfToMarkdownPage();
        case 'AI: Convert PDF to CSV':
          return const AiPdfToCsvPage();
        case 'AI: Convert PDF to Excel':
          return const AiPdfToExcelPage();
        case 'Convert HTML to PDF':
          return const HtmlToPdfPage();
        case 'Convert Word to PDF':
          return const WordToPdfPage();
        case 'Convert PowerPoint to PDF':
          return const PowerPointToPdfPage();
        case 'Convert OXPS to PDF':
          return const OxpsToPdfPage();
        case 'Convert JPG to PDF':
          return const JpgToPdfPage();
        case 'Convert PNG to PDF':
          return const PngToPdfPage();
        case 'Convert Markdown to PDF':
          return const MarkdownToPdfPage();
        case 'Convert Excel to PDF':
          return const ExcelToPdfPage();
        case 'Convert Excel to XPS':
          return const ExcelToXpsPage();
        case 'Convert OpenOffice Calc ODS to PDF':
          return const OdsToPdfFromPdfCategoryPage();
        case 'Convert PDF to CSV':
          return const PdfToCsvPage();
        case 'Convert PDF to Excel':
          return const PdfToExcelPage();
        case 'Convert PDF to Word':
          return const PdfToWordPage();
        case 'Convert PDF to JPG':
          return const PdfToJpgPage();
        case 'Convert PDF to PNG':
          return const PdfToPngPage();
        case 'Convert PDF to TIFF':
          return const PdfToTiffPage();
        case 'Convert PDF to SVG':
          return const PdfToSvgPage();
        case 'Convert PDF to HTML':
          return const PdfToHtmlPage();
        case 'Convert PDF to Text':
          return const PdfToTextPage();
      }
    }

    if (categoryId == 'website_conversion') {
      switch (toolName) {
        case 'Convert Website to PDF':
          return const WebsiteToPdfPage();
        case 'Convert HTML to PDF':
          return HtmlToPdfPage(categoryId: categoryId);
        case 'Convert Word to HTML':
          return const WordToHtmlPage();
        case 'Convert PowerPoint to HTML':
          return const PowerPointToHtmlPage();
        case 'Convert Markdown to HTML':
          return const MarkdownToHtmlPage();
        case 'Convert Website to JPG':
          return const WebsiteToJpgPage();
        case 'Convert HTML to JPG':
          return const HtmlToJpgPage();
        case 'Convert Website to PNG':
          return const WebsiteToPngPage();
        case 'Convert HTML to PNG':
          return const HtmlToPngPage();
        case 'Convert HTML Table to CSV':
          return const HtmlTableToCsvPage();
        case 'Convert Excel to HTML':
          return const ExcelToHtmlWebPage();
        case 'Convert PDF to HTML':
          return const PdfToHtmlWebPage();
      }
    }

    if (categoryId == 'video_conversion') {
      switch (toolName) {
        case 'Convert MOV to MP4':
          return const MovToMp4Page();
        case 'Convert MKV to MP4':
          return const MkvToMp4Page();
        case 'Convert AVI to MP4':
          return const AviToMp4Page();
        case 'Convert MP4 to MP3':
          return const Mp4ToMp3Page();
      }
    }

    if (categoryId == 'audio_conversion') {
      switch (toolName) {
        case 'Convert MP4 to MP3':
          return const Mp4ToMp3FromAudioPage();
        case 'Convert WAV to MP3':
          return const WavToMp3Page();
        case 'Convert FLAC to MP3':
          return const FlacToMp3Page();
        case 'Convert MP3 to WAV':
          return const Mp3ToWavPage();
        case 'Convert FLAC to WAV':
          return const FlacToWavPage();
        case 'Convert WAV to FLAC':
          return const WavToFlacPage();
      }
    }

    if (categoryId == 'subtitle_conversion') {
      switch (toolName) {
        case 'AI: Translate SRT':
          return const AiTranslateSrtPage();
        case 'Convert SRT to CSV':
          return const SrtToCsvFromSubtitlePage();
        case 'Convert SRT to Excel':
          return const SrtToExcelPage();
        case 'Convert SRT to Text':
          return const SrtToTextPage();
        case 'Convert SRT to VTT':
          return const SrtToVttPage();
        case 'Convert VTT to Text':
          return const VttToTextPage();
        case 'Convert VTT to SRT':
          return const VttToSrtPage();
        case 'Convert CSV to SRT':
          return const CsvToSrtFromSubtitlePage();
        case 'Convert Excel to SRT':
          return const ExcelToSrtPage();
      }
    }

    if (categoryId == 'text_conversion') {
      switch (toolName) {
        case 'Convert Word to Text':
          return const WordToTextTextPage();
        case 'Convert PowerPoint to Text':
          return const PowerPointToTextPage();
        case 'Convert PDF to Text':
          return const PdfToTextTextPage();
        case 'Convert SRT to Text':
          return const SrtToTextFromTextPage();
        case 'Convert VTT to Text':
          return const VttToTextFromTextPage();
      }
    }

    if (categoryId == 'file_formatter') {
      switch (toolName) {
        case 'JSON Formatter':
          return const JsonFormatterToolPage();
        case 'JSON Validator':
          return const JsonValidatorPage();
        case 'XML/XSD Validator':
          return const XmlXsdValidatorPage();
      }
    }

    if (categoryId == 'ebook_conversion') {
      switch (toolName) {
        case 'Convert Markdown to ePUB':
          return const MarkdownToEpubPage();
        case 'Convert ePUB to MOBI':
          return const EpubToMobiPage();
        case 'Convert ePUB to AZW':
          return const EpubToAzwPage();
        case 'Convert MOBI to ePUB':
          return const MobiToEpubPage();
        case 'Convert MOBI to AZW':
          return const MobiToAzwPage();
        case 'Convert AZW to ePUB':
          return const AzwToEpubPage();
        case 'Convert AZW to MOBI':
          return const AzwToMobiPage();
        case 'Convert ePUB to PDF':
          return const EpubToPdfPage();
        case 'Convert MOBI to PDF':
          return const MobiToPdfPage();
        case 'Convert AZW to PDF':
          return const AzwToPdfPage();
        case 'Convert AZW3 to PDF':
          return const Azw3ToPdfPage();
        case 'Convert FB2 to PDF':
          return const Fb2ToPdfPage();
        case 'Convert FBZ to PDF':
          return const FbzToPdfPage();
        case 'Convert PDF to ePUB':
          return const PdfToEpubPage();
        case 'Convert PDF to MOBI':
          return const PdfToMobiPage();
        case 'Convert PDF to AZW':
          return const PdfToAzwPage();
        case 'Convert PDF to AZW3':
          return const PdfToAzw3Page();
        case 'Convert PDF to FB2':
          return const PdfToFb2Page();
        case 'Convert PDF to FBZ':
          return const PdfToFbzPage();
      }
    }

    if (categoryId == 'image_conversion') {
      switch (toolName) {
        case 'AI: Convert PNG to JSON':
          return const AiPngToJsonImagePage();
        case 'AI: Convert JPG to JSON':
          return const AiJpgToJsonImagePage();
        case 'Convert JPG to PDF':
          return const JpgToPdfPage();
        case 'Convert PNG to PDF':
          return const PngToPdfPage();
        case 'Convert Website to JPG':
          return const WebsiteToJpgPage();
        case 'Convert HTML to JPG':
          return const HtmlToJpgPage();
        case 'Convert Website to PNG':
          return const WebsiteToPngPage();
        case 'Convert HTML to PNG':
          return const HtmlToPngPage();
        case 'Convert PDF to JPG':
          return const PdfToJpgImagePage(useImageCategoryStorage: true);
        case 'Convert PDF to PNG':
          return const PdfToPngImagePage(useImageCategoryStorage: true);
        case 'Convert PDF to TIFF':
          return const PdfToTiffImagePage(useImageCategoryStorage: true);
        case 'Convert PDF to SVG':
          return const PdfToSvgImagePage(useImageCategoryStorage: true);
        case 'Convert AI to SVG':
          return const AiToSvgImagePage();
        // Remaining format conversions can initially route to generic ToolActionPage
        default:
          return ToolActionPage(
            categoryId: categoryId,
            toolName: toolName,
            categoryIcon: Icons.image_outlined,
          );
      }
    }

    if (categoryId == 'ocr_conversion') {
      switch (toolName) {
        case 'OCR: Convert PNG to Text':
          return const OcrPngToTextPage();
        case 'OCR: Convert JPG to Text':
          return const OcrJpgToTextPage();
        case 'OCR: Convert PNG to PDF':
          return const OcrPngToPdfPage();
        case 'OCR: Convert JPG to PDF':
          return const OcrJpgToPdfPage();
        case 'OCR: Convert PDF to Text':
          return const OcrPdfToTextPage();
        case 'OCR: Convert PDF Image to PDF Text':
          return const OcrPdfImageToPdfTextPage();
      }
    }

    // Fallback generic page
    return ToolActionPage(
      categoryId: categoryId,
      toolName: toolName,
      categoryIcon: categoryIcon,
    );
  }
}
