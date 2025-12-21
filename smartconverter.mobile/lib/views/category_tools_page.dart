import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../services/favorites_provider.dart';
import '../constants/app_colors.dart';
import '../constants/api_config.dart';
import 'tool_action_page.dart';
// JSON pages
import 'conversions/json/json_to_xml_page.dart';
import 'conversions/json/json_objects_to_csv_page.dart';
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
import 'conversions/office_documents/pdf_to_csv_page.dart';
import 'conversions/office_documents/pdf_to_excel_page.dart';
import 'conversions/office_documents/word_to_html_page.dart';
import 'conversions/office_documents/powerpoint_to_html_page.dart';
import 'conversions/office_documents/powerpoint_to_text_page.dart';
import 'conversions/office_documents/excel_to_xps_page.dart';
import 'conversions/office_documents/excel_to_html_page.dart';
import 'conversions/office_documents/ods_to_csv_page.dart';
import 'conversions/office_documents/ods_to_pdf_page.dart';
import 'conversions/office_documents/csv_to_excel_page.dart';
import 'conversions/office_documents/excel_to_xml_page.dart';
import 'conversions/office_documents/xml_to_csv_page.dart';
import 'conversions/office_documents/xml_to_excel_page.dart';
import 'conversions/office_documents/json_to_excel_page.dart';
import 'conversions/office_documents/excel_to_json_page.dart';
import 'conversions/office_documents/json_objects_to_excel_page.dart';
import 'conversions/office_documents/srt_to_excel_page.dart';
import 'conversions/office_documents/excel_to_srt_page.dart';
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
import 'conversions/audio/convert_audio_format_page.dart';
import 'conversions/audio/normalize_audio_page.dart';
import 'conversions/audio/trim_audio_page.dart';
import 'conversions/audio/get_audio_info_page.dart';
import 'conversions/audio/supported_audio_formats_page.dart';
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
import 'conversions/file_formatter/json_formatter_tool_page.dart' as ff_json_format;
import 'conversions/file_formatter/json_validator_page.dart' as ff_json_validate;
import 'conversions/file_formatter/xml_validator_page.dart' as ff_xml_validate;
import 'conversions/file_formatter/xsd_validator_page.dart' as ff_xsd_validate;
import 'conversions/file_formatter/minify_json_page.dart' as ff_json_minify;
import 'conversions/file_formatter/format_xml_page.dart' as ff_xml_format;
import 'conversions/file_formatter/json_schema_info_page.dart' as ff_json_schema;
import 'conversions/file_formatter/supported_file_formats_page.dart' as ff_formats;
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
import 'conversions/image/pdf_to_image_page.dart'; // Handles PNG, TIFF, SVG
import 'conversions/image/ai_to_svg_page.dart';
import 'conversions/image/image_format_conversion_page.dart';
import 'conversions/image/remove_exif_page.dart';
import 'conversions/image/png_to_svg_page.dart';
import 'conversions/image/png_to_avif_page.dart';
import 'conversions/image/jpg_to_avif_page.dart';
import 'conversions/image/webp_to_avif_page.dart';
import 'conversions/image/avif_to_png_page.dart';
import 'conversions/image/avif_to_jpeg_page.dart';
import 'conversions/image/avif_to_webp_page.dart';
import 'conversions/image/png_to_webp_page.dart';
import 'conversions/image/jpg_to_webp_page.dart';
import 'conversions/image/tiff_to_webp_page.dart';
import 'conversions/image/gif_to_webp_page.dart';
import 'conversions/image/webp_to_png_page.dart';
import 'conversions/image/webp_to_jpeg_page.dart';
import 'conversions/image/webp_to_tiff_page.dart';
import 'conversions/image/webp_to_bmp_page.dart';
import 'conversions/image/webp_to_yuv_page.dart';
import 'conversions/image/webp_to_pam_page.dart';
import 'conversions/image/webp_to_pgm_page.dart';
import 'conversions/image/webp_to_ppm_page.dart';
import 'conversions/image/png_to_jpg_page.dart';
import 'conversions/image/png_to_pgm_page.dart';
import 'conversions/image/png_to_ppm_page.dart';
import 'conversions/image/jpg_to_png_page.dart';
import 'conversions/image/jpeg_to_pgm_page.dart';
import 'conversions/image/jpeg_to_ppm_page.dart';
import 'conversions/image/heic_to_png_page.dart';
import 'conversions/image/heic_to_jpg_page.dart';
import 'conversions/image/svg_to_png_page.dart';
import 'conversions/image/svg_to_jpg_page.dart';
// Reuse website converters for site/html to images (already imported above)
// OCR pages
import 'conversions/ocr/png_to_text_page.dart';
import 'conversions/ocr/jpg_to_text_page.dart';
import 'conversions/ocr/png_to_pdf_page.dart';
import 'conversions/ocr/jpg_to_pdf_page.dart';
import 'conversions/ocr/pdf_to_text_page.dart';
import 'conversions/ocr/pdf_image_to_pdf_text_page.dart';

import 'conversions/ebook/markdown_to_epub_page.dart';
import 'conversions/ebook/epub_to_mobi_page.dart';
import 'conversions/ebook/epub_to_azw_page.dart';
import 'conversions/ebook/mobi_to_epub_page.dart';
import 'conversions/ebook/mobi_to_azw_page.dart';
import 'conversions/ebook/azw_to_epub_page.dart';
import 'conversions/ebook/azw_to_mobi_page.dart';
import 'conversions/ebook/epub_to_pdf_page.dart';
import 'conversions/ebook/mobi_to_pdf_page.dart';
import 'conversions/ebook/azw_to_pdf_page.dart';
import 'conversions/ebook/azw3_to_pdf_page.dart';
import 'conversions/ebook/fb2_to_pdf_page.dart';
import 'conversions/ebook/fbz_to_pdf_page.dart';
import 'conversions/ebook/pdf_to_epub_page.dart';
import 'conversions/ebook/pdf_to_mobi_page.dart';
import 'conversions/ebook/pdf_to_azw_page.dart';
import 'conversions/ebook/pdf_to_azw3_page.dart';
import 'conversions/ebook/pdf_to_fb2_page.dart';
import 'conversions/ebook/pdf_to_fbz_page.dart';

import 'conversions/video/mov_to_mp4_page.dart';
import 'conversions/video/mkv_to_mp4_page.dart';
import 'conversions/video/avi_to_mp4_page.dart';
import 'conversions/video/mp4_to_mp3_page.dart';
import 'conversions/video/convert_video_format_page.dart';
import 'conversions/video/video_to_audio_page.dart';
import 'conversions/video/extract_audio_page.dart';
import 'conversions/video/resize_video_page.dart';
import 'conversions/video/compress_video_page.dart';
import 'conversions/video/get_video_info_page.dart';
import 'conversions/video/supported_formats_page.dart';

class CategoryToolsPage extends StatefulWidget {
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
  State<CategoryToolsPage> createState() => _CategoryToolsPageState();

  static Widget resolveToolPage(
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
          return const JsonToExcelOfficePage();
        case 'Convert Excel to JSON':
          return const ExcelToJsonOfficePage();
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
          return const ExcelToXmlOfficePage();
        case 'Convert XML to JSON':
          return const XmlToJsonFromXmlCategoryPage();
        case 'Convert XML to CSV':
          return const XmlToCsvOfficePage();
        case 'Convert XML to Excel':
          return const XmlToExcelOfficePage();
        case 'Fix XML Escaping':
          return const XmlFixEscapingPage();

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
          return const OdsToCsvOfficePage();
        case 'Convert CSV to Excel':
          return const CsvToExcelOfficePage();
        case 'Convert CSV to XML':
          return const CsvToXmlPage();
        case 'Convert XML to CSV':
          return const XmlToCsvFromCsvCategoryPage();
        case 'Convert PDF to CSV':
          return const PdfToCsvOfficePage();
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
          return const WordToPdfOfficePage();
        case 'Convert Word to HTML':
          return const WordToHtmlOfficePage();
        case 'Convert PowerPoint to PDF':
          return const PowerPointToPdfOfficePage();
        case 'Convert PowerPoint to HTML':
          return const PowerPointToHtmlOfficePage();
        case 'Convert OXPS to PDF':
          return const OxpsToPdfPage();
        case 'Convert Word to Text':
          return const WordToTextOfficePage();
        case 'Convert PowerPoint to Text':
          return const PowerPointToTextOfficePage();
        case 'Convert Excel to PDF':
          return const ExcelToPdfOfficePage();
        case 'Convert Excel to XPS':
          return const ExcelToXpsOfficePage();
        case 'Convert Excel to HTML':
          return const ExcelToHtmlOfficePage();
        case 'Convert Excel to CSV':
          return const ExcelToCsvOfficePage();
        case 'Convert Excel to OpenOffice Calc ODS':
          return const ExcelToOdsOfficePage();
        case 'Convert OpenOffice Calc ODS to CSV':
          return const OdsToCsvOfficePage();
        case 'Convert OpenOffice Calc ODS to PDF':
          return const OdsToPdfOfficePage();
        case 'Convert OpenOffice Calc ODS to Excel':
          return const OdsToExcelOfficePage();
        case 'Convert CSV to Excel':
          return const CsvToExcelOfficePage();
        case 'Convert Excel to XML':
          return const ExcelToXmlOfficePage();
        case 'Convert XML to CSV':
          return const XmlToCsvOfficePage();
        case 'Convert XML to Excel':
          return const XmlToExcelOfficePage();

        case 'Convert PDF to CSV':
          return const PdfToCsvOfficePage();
        case 'Convert PDF to Excel':
          return const PdfToExcelOfficePage();
        case 'Convert PDF to Word':
          return const PdfToWordOfficePage();
        case 'Convert JSON to Excel':
          return const JsonToExcelOfficePage();
        case 'Convert Excel to JSON':
          return const ExcelToJsonOfficePage();
        case 'Convert JSON objects to Excel':
          return const JsonObjectsToExcelOfficePage();
        case 'Convert BSON to Excel':
          return const BsonToExcelOfficePage();
        case 'Convert SRT to Excel':
          return const SrtToExcelOfficePage();
        case 'Convert Excel to SRT':
          return const ExcelToSrtOfficePage();
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
          return const WordToPdfOfficePage();
        case 'Convert PowerPoint to PDF':
          return const PowerPointToPdfOfficePage();
        case 'Convert OXPS to PDF':
          return const OxpsToPdfPage();
        case 'Convert JPG to PDF':
          return const JpgToPdfPage();
        case 'Convert PNG to PDF':
          return const PngToPdfPage();
        case 'Convert Markdown to PDF':
          return const MarkdownToPdfPage();
        case 'Convert Excel to PDF':
          return const ExcelToPdfOfficePage();
        case 'Convert Excel to XPS':
          return const ExcelToXpsOfficePage();
        case 'Convert OpenOffice Calc ODS to PDF':
          return const OdsToPdfOfficePage();
        case 'Convert PDF to CSV':
          return const PdfToCsvOfficePage();
        case 'Convert PDF to Excel':
          return const PdfToExcelOfficePage();
        case 'Convert PDF to Word':
          return const PdfToWordOfficePage();
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
          return const SrtToExcelOfficePage();
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
          return const AiPngToJsonPage();
        case 'AI: Convert JPG to JSON':
          return const AiJpgToJsonPage();
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
          return const PdfToImagePage(initialFormat: 'PNG');
        case 'Convert PDF to TIFF':
          return const PdfToImagePage(initialFormat: 'TIFF');
        case 'Convert PDF to SVG':
          return const PdfToImagePage(initialFormat: 'SVG');
        case 'Convert AI to SVG':
          return const AiToSvgPage();
        case 'Convert PNG to SVG':
          return const PngToSvgPage();
        case 'Convert PNG to AVIF':
          return const PngToAvifPage();
        case 'Convert JPG to AVIF':
          return const JpgToAvifPage();
        case 'Convert WebP to AVIF':
          return const WebpToAvifPage();
        case 'Convert AVIF to PNG':
          return const AvifToPngPage();
        case 'Convert AVIF to JPEG':
           return const AvifToJpegPage();
        case 'Convert AVIF to WebP':
           return const AvifToWebpPage();
        case 'Convert PNG to WebP':
          return const PngToWebpPage();
        case 'Convert JPG to WebP':
          return const JpgToWebpPage();
        case 'Convert TIFF to WebP':
          return const TiffToWebpPage();
        case 'Convert GIF to WebP':
          return const GifToWebpPage();
        case 'Convert WebP to PNG':
          return const WebpToPngPage();
        case 'Convert WebP to JPEG':
          return const WebpToJpegPage();
        case 'Convert WebP to TIFF':
          return const WebpToTiffPage();
        case 'Convert WebP to BMP':
          return const WebpToBmpPage();
        case 'Convert WebP to YUV':
           return const WebpToYuvPage();
        case 'Convert WebP to PAM':
           return const WebpToPamPage();
        case 'Convert WebP to PGM':
           return const WebpToPgmPage();
        case 'Convert WebP to PPM':
           return const WebpToPpmPage();
        case 'Convert PNG to JPG':
           return const PngToJpgPage();
        case 'Convert PNG to PGM':
           return const PngToPgmPage();
        case 'Convert PNG to PPM':
           return const PngToPpmPage();
        case 'Convert JPG to PNG':
           return const JpgToPngPage();
        case 'Convert JPEG to PGM':
           return const JpegToPgmPage();
        case 'Convert JPEG to PPM':
           return const JpegToPpmPage();
        case 'Convert HEIC to PNG':
           return const HeicToPngPage();
        case 'Convert HEIC to JPG':
           return const HeicToJpgPage();
        case 'Convert SVG to PNG':
           return const SvgToPngPage();
        case 'Convert SVG to JPG':
           return const SvgToJpgPage();
        case 'Remove EXIF Data':
          return const RemoveExifPage();
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

    if (categoryId == 'ebook_conversion') {
      switch (toolName) {
        case 'Convert Markdown To Epub':
          return const MarkdownToEpubPage();
        case 'Convert Epub To Mobi':
          return const EpubToMobiPage();
        case 'Convert Epub To Azw':
          return const EpubToAzwPage();
        case 'Convert Mobi To Epub':
          return const MobiToEpubPage();
        case 'Convert Mobi To Azw':
          return const MobiToAzwPage();
        case 'Convert Azw To Epub':
          return const AzwToEpubPage();
        case 'Convert Azw To Mobi':
          return const AzwToMobiPage();
        case 'Convert Epub To Pdf':
          return const EpubToPdfPage();
        case 'Convert Mobi To Pdf':
          return const MobiToPdfPage();
        case 'Convert Azw To Pdf':
          return const AzwToPdfPage();
        case 'Convert Azw3 To Pdf':
          return const Azw3ToPdfPage();
        case 'Convert Fb2 To Pdf':
          return const Fb2ToPdfPage();
        case 'Convert Fbz To Pdf':
          return const FbzToPdfPage();
        case 'Convert Pdf To Epub':
          return const PdfToEpubPage();
        case 'Convert Pdf To Mobi':
          return const PdfToMobiPage();
        case 'Convert Pdf To Azw':
          return const PdfToAzwPage();
        case 'Convert Pdf To Azw3':
          return const PdfToAzw3Page();
        case 'Convert Pdf To Fb2':
          return const PdfToFb2Page();
        case 'Convert Pdf To Fbz':
          return const PdfToFbzPage();
      }
    }

    if (categoryId == 'video_conversion') {
      switch (toolName) {
        case 'Convert Mov To Mp4':
          return const MovToMp4Page();
        case 'Convert Mkv To Mp4':
          return const MkvToMp4Page();
        case 'Convert Avi To Mp4':
          return const AviToMp4Page();
        case 'Convert Mp4 To Mp3':
          return const Mp4ToMp3Page();
        case 'Convert Video Format':
          return const ConvertVideoFormatPage();
        case 'Video To Audio':
          return const VideoToAudioPage();
        case 'Extract Audio':
          return const ExtractAudioPage();
        case 'Resize Video':
          return const ResizeVideoPage();
        case 'Compress Video':
          return const CompressVideoPage();
        case 'Get Video Info':
          return const GetVideoInfoPage();
        case 'Supported Formats':
          return const SupportedFormatsPage();
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
        case 'Convert Audio Format':
          return const ConvertAudioFormatPage();
        case 'Normalize Audio':
          return const NormalizeAudioPage();
        case 'Trim Audio':
          return const TrimAudioPage();
        case 'Get Audio Info':
          return const GetAudioInfoPage();
        case 'Supported Audio Formats':
          return const SupportedAudioFormatsPage();
      }
    }

    if (categoryId == 'file_formatter') {
      switch (toolName) {
        case 'Format JSON':
          return const ff_json_format.JsonFormatterPage();
        case 'Validate JSON':
          return const ff_json_validate.JsonValidationPage();
        case 'Validate XML':
          return const ff_xml_validate.XmlValidatorPage();
        case 'Validate XSD':
          return const ff_xsd_validate.XsdValidatorPage();
        case 'Minify JSON':
          return const ff_json_minify.JsonMinifierPage();
        case 'Format XML':
          return const ff_xml_format.XmlFormatterPage();
        case 'Get JSON Schema Info':
          return const ff_json_schema.JsonSchemaInfoPage();
        case 'Supported File Formats':
          return const ff_formats.SupportedFileFormatsPage();
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

class _CategoryToolsPageState extends State<CategoryToolsPage> {
  late TextEditingController _searchController;
  late List<String> _filteredTools;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredTools = widget.tools;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterTools(String query) {
    setState(() {
      _filteredTools = widget.tools
          .where((tool) => tool.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.name,
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
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildToolsList(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to get icon for a format
  IconData _getFormatIcon(String format) {
    final f = format.toLowerCase();
    if (f.contains('pdf')) return Icons.picture_as_pdf;
    if (f.contains('image') || f.contains('png') || f.contains('jpg') || f.contains('jpeg')) return Icons.image;
    if (f.contains('excel') || f.contains('xls') || f.contains('sheet')) return Icons.table_chart;
    if (f.contains('csv')) return Icons.grid_on;
    if (f.contains('xml')) return Icons.code;
    if (f.contains('json')) return Icons.data_object;
    if (f.contains('yaml') || f.contains('yml')) return Icons.list_alt;
    if (f.contains('html') || f.contains('web') || f.contains('site')) return Icons.language;
    if (f.contains('word') || f.contains('doc')) return Icons.description;
    if (f.contains('text') || f.contains('txt')) return Icons.text_fields;
    if (f.contains('powerpoint') || f.contains('ppt') || f.contains('slides')) return Icons.slideshow;
    if (f.contains('audio') || f.contains('mp3') || f.contains('wav') || f.contains('sound') || f.contains('flac')) return Icons.audiotrack;
    if (f.contains('video') || f.contains('mp4') || f.contains('avi') || f.contains('mov') || f.contains('mkv')) return Icons.movie;
    if (f.contains('ebook') || f.contains('epub') || f.contains('mobi') || f.contains('azw') || f.contains('fb2')) return Icons.book;
    if (f.contains('zip') || f.contains('rar') || f.contains('7z') || f.contains('archive')) return Icons.folder_zip;
    if (f.contains('svg')) return Icons.photo_size_select_large;
    
    return Icons.insert_drive_file;
  }

  // Parse tool name to get source and destination formats (generic for all categories)
  Map<String, String>? _parseToolFormats(String toolName) {
    // 1. "AI: Convert X to Y"
    final aiMatch = RegExp(r'AI:\s*Convert\s+(\w+)\s+to\s+(\w+)', caseSensitive: false)
        .firstMatch(toolName);
    if (aiMatch != null) {
      return {'source': aiMatch.group(1)!, 'destination': aiMatch.group(2)!};
    }

    // 2. "Convert X to Y" (handles "Convert JSON objects to CSV" etc)
    // Using (.+?) to capture multi-word formats like "OpenOffice Calc ODS"
    final convertMatch = RegExp(r'Convert\s+(.+?)\s+to\s+(.+)', caseSensitive: false)
        .firstMatch(toolName);
    if (convertMatch != null) {
      return {'source': convertMatch.group(1)!, 'destination': convertMatch.group(2)!};
    }

    // 3. "X to Y" (fallback)
    final simpleMatch = RegExp(r'(.+?)\s+to\s+(.+)', caseSensitive: false)
        .firstMatch(toolName);
    if (simpleMatch != null) {
      // Must contain "to" as whole word to avoid false positives in names? 
      // The regex requires space around "to".
      return {'source': simpleMatch.group(1)!, 'destination': simpleMatch.group(2)!};
    }

    return null;
  }

  // Build icon widget for a tool
  Widget _buildToolIcon(String toolName) {
    final formats = _parseToolFormats(toolName);
    
    if (formats != null) {
      // Show diagonal layout: source (top-left) ↘ destination (bottom-right)
      return Container(
        width: 52,
        height: 52,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue.withOpacity(0.15),
              AppColors.primaryBlue.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Source icon - top left
            Positioned(
              top: 2,
              left: 2,
              child: Icon(
                _getFormatIcon(formats['source']!),
                size: 18,
                color: AppColors.primaryBlue,
              ),
            ),
            // Destination icon - bottom right
            Positioned(
              bottom: 2,
              right: 2,
              child: Icon(
                _getFormatIcon(formats['destination']!),
                size: 18,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      );
    }
    
    // Default single icon for non-conversion tools (Formatter, Validator, etc.)
    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withOpacity(0.15),
            AppColors.primaryBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          widget.icon,
          size: 24,
          color: AppColors.primaryBlue,
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
            child: Icon(widget.icon, color: AppColors.textPrimary, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.name,
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
                  '${widget.tools.length}',
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

  Widget _buildSearchBar() {
    return Container(
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
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.textPrimary),
        onChanged: _filterTools,
        decoration: InputDecoration(
          hintText: 'Search tools...',
          hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
          suffixIcon: const Icon(Icons.search, color: AppColors.primaryBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildToolsList(BuildContext context) {
    if (_filteredTools.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No tools found',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _filteredTools.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final toolName = _filteredTools[index];
            void handleTap() {
              final page = CategoryToolsPage.resolveToolPage(context, widget.id, toolName, widget.icon);
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
                      _buildToolIcon(toolName),
                      const SizedBox(width: 19),
                      Expanded(
                        child: Text(
                          toolName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Consumer<FavoritesProvider>(
                        builder: (context, provider, child) {
                          final isFav = provider.isFavorite(widget.id, toolName);
                          return IconButton(
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: isFav ? AppColors.primaryBlue : AppColors.textSecondary,
                            ),
                            onPressed: () => provider.toggleFavorite(
                              categoryId: widget.id,
                              toolName: toolName,
                              categoryIcon: widget.icon,
                            ),
                          );
                        },
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
}
