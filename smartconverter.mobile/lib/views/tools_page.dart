import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_drawer.dart';
import 'category_tools_page.dart';

class ToolsPage extends StatefulWidget {
  final int selectedIndex;

  const ToolsPage({super.key, this.selectedIndex = 1});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _allTools = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAllTools();
    _startAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );
  }

  void _loadAllTools() {
    // Main Conversion Categories
    _allTools.addAll([
      {
        'id': 'json_conversion',
        'name': 'JSON Conversion',
        'description': 'Convert JSON data to various formats',
        'icon': Icons.data_object,
        'category': 'Data Conversion',
        'tools': [
          'AI: Convert PDF to JSON',
          'AI: Convert PNG to JSON',
          'AI: Convert JPG to JSON',
          'Convert XML to JSON',
          'JSON Formatter',
          'JSON Validator',
          'Convert JSON to XML',
          'Convert JSON to CSV',
          'Convert JSON to Excel',
          'Convert Excel to JSON',
          'Convert CSV to JSON',
          'Convert JSON to YAML',
          'Convert JSON objects to CSV',
          'Convert JSON objects to Excel',
          'Convert YAML to JSON',
        ],
      },
      {
        'id': 'xml_conversion',
        'name': 'XML Conversion',
        'description': 'Convert XML data to various formats',
        'icon': Icons.schema_outlined,
        'category': 'Data Conversion',
        'tools': [
          'Convert CSV to XML',
          'Convert Excel to XML',
          'Convert XML to JSON',
          'Convert XML to CSV',
          'Convert XML to Excel',
          'Fix XML Escaping',

          'XML/XSD Validator',
          'Convert JSON to XML',
        ],
      },
      {
        'id': 'csv_conversion',
        'name': 'CSV Conversion',
        'description': 'Convert CSV data to various formats',
        'icon': Icons.table_chart_outlined,
        'category': 'Data Conversion',
        'tools': [
          'AI: Convert PDF to CSV',
          'Convert HTML Table to CSV',
          'Convert Excel to CSV',
          'Convert OpenOffice Calc ODS to CSV',
          'Convert CSV to Excel',
          'Convert CSV to XML',
          'Convert XML to CSV',
          'Convert PDF to CSV',
          'Convert JSON to CSV',
          'Convert CSV to JSON',
          'Convert JSON objects to CSV',
          'Convert BSON to CSV',
          'Convert SRT to CSV',
          'Convert CSV to SRT',
        ],
      },
      {
        'id': 'office_documents_conversion',
        'name': 'Office Documents Conversion',
        'description': 'Convert Office documents (Word, Excel, PowerPoint)',
        'icon': Icons.description_outlined,
        'category': 'Document Conversion',
        'tools': [
          'AI: Convert PDF to CSV',
          'AI: Convert PDF to Excel',
          'Convert Word to PDF',
          'Convert Word to HTML',
          'Convert PowerPoint to PDF',
          'Convert PowerPoint to HTML',
          'Convert OXPS to PDF',
          'Convert Word to Text',
          'Convert PowerPoint to Text',
          'Convert Excel to PDF',
          'Convert Excel to XPS',
          'Convert Excel to HTML',
          'Convert Excel to CSV',
          'Convert Excel to OpenOffice Calc ODS',
          'Convert OpenOffice Calc ODS to CSV',
          'Convert OpenOffice Calc ODS to PDF',
          'Convert OpenOffice Calc ODS to Excel',
          'Convert CSV to Excel',
          'Convert Excel to XML',
          'Convert XML to CSV',
          'Convert XML to Excel',

          'Convert PDF to CSV',
          'Convert PDF to Excel',
          'Convert PDF to Word',
          'Convert JSON to Excel',
          'Convert Excel to JSON',
          'Convert JSON objects to Excel',
          'Convert BSON to Excel',
          'Convert SRT to Excel',
          'Convert SRT to XLSX',
          'Convert SRT to XLS',
          'Convert Excel to SRT',
          'Convert XLSX to SRT',
          'Convert XLS to SRT',
        ],
      },
      {
        'id': 'pdf_conversion',
        'name': 'PDF Conversion',
        'description': 'Convert and manipulate PDF documents',
        'icon': Icons.picture_as_pdf_outlined,
        'category': 'PDF Tools',
        'tools': [
          'Merge PDF',
          'Split PDF',
          'Compress PDF',
          'Remove Pages',
          'Extract Pages',
          'Rotate PDF',
          'Add Watermark',
          'Add Page Numbers',
          'Crop PDF',
          'Protect PDF',
          'Unlock PDF',
          'Repair PDF',
          'Compare PDFs',
          'Get PDF Metadata',
          'AI: Convert PDF to JSON',
          'AI: Convert PDF to Markdown',
          'AI: Convert PDF to CSV',
          'AI: Convert PDF to Excel',
          'Convert HTML to PDF',
          'Convert Word to PDF',
          'Convert PowerPoint to PDF',
          'Convert OXPS to PDF',
          'Convert JPG to PDF',
          'Convert PNG to PDF',
          'Convert Markdown to PDF',
          'Convert Excel to PDF',
          'Convert Excel to XPS',
          'Convert OpenOffice Calc ODS to PDF',
          'Convert PDF to CSV',
          'Convert PDF to Excel',
          'Convert PDF to Word',
          'Convert PDF to JPG',
          'Convert PDF to PNG',
          'Convert PDF to TIFF',
          'Convert PDF to SVG',
          'Convert PDF to HTML',
          'Convert PDF to Text',
        ],
      },
      {
        'id': 'image_conversion',
        'name': 'Image Conversion',
        'description': 'Convert and process image files',
        'icon': Icons.image_outlined,
        'category': 'Media Conversion',
        'tools': [
          'AI: Convert PNG to JSON',
          'AI: Convert JPG to JSON',
          'Convert JPG to PDF',
          'Convert PNG to PDF',
          'Convert Website to JPG',
          'Convert HTML to JPG',
          'Convert Website to PNG',
          'Convert HTML to PNG',
          'Convert PDF to JPG',
          'Convert PDF to PNG',
          'Convert PDF to TIFF',
          'Convert PDF to SVG',
          'Convert AI to SVG',
          'Convert PNG to SVG',
          'Convert PNG to AVIF',
          'Convert JPG to AVIF',
          'Convert WebP to AVIF',
          'Convert AVIF to PNG',
          'Convert AVIF to JPEG',
          'Convert AVIF to WebP',
          'Convert PNG to WebP',
          'Convert JPG to WebP',
          'Convert TIFF to WebP',
          'Convert GIF to WebP',
          'Convert WebP to PNG',
          'Convert WebP to JPEG',
          'Convert WebP to TIFF',
          'Convert WebP to BMP',
          'Convert WebP to YUV',
          'Convert WebP to PAM',
          'Convert WebP to PGM',
          'Convert WebP to PPM',
          'Convert PNG to JPG',
          'Convert PNG to PGM',
          'Convert PNG to PPM',
          'Convert JPG to PNG',
          'Convert JPEG to PGM',
          'Convert JPEG to PPM',
          'Convert HEIC to PNG',
          'Convert HEIC to JPG',
          'Convert SVG to PNG',
          'Convert SVG to JPG',
          'Remove EXIF Data',
        ],
      },
      {
        'id': 'ocr_conversion',
        'name': 'OCR Conversion',
        'description': 'Extract text from images and documents',
        'icon': Icons.document_scanner_outlined,
        'category': 'Text Processing',
        'tools': [
          'OCR: Convert PNG to Text',
          'OCR: Convert JPG to Text',
          'OCR: Convert PNG to PDF',
          'OCR: Convert JPG to PDF',
          'OCR: Convert PDF to Text',
          'OCR: Convert PDF Image to PDF Text',
        ],
      },
      {
        'id': 'website_conversion',
        'name': 'Website Conversion',
        'description': 'Convert websites and HTML content',
        'icon': Icons.public_outlined,
        'category': 'Web Tools',
        'tools': [
          'Convert Website to PDF',
          'Convert HTML to PDF',
          'Convert Word to HTML',
          'Convert PowerPoint to HTML',
          'Convert Markdown to HTML',
          'Convert Website to JPG',
          'Convert HTML to JPG',
          'Convert Website to PNG',
          'Convert HTML to PNG',
          'Convert HTML Table to CSV',
          'Convert Excel to HTML',
          'Convert PDF to HTML',
        ],
      },
      {
        'id': 'video_conversion',
        'name': 'Video Conversion',
        'description': 'Convert and process video files',
        'icon': Icons.movie_creation_outlined,
        'category': 'Media Conversion',
        'tools': [
          'Convert MOV to MP4',
          'Convert MKV to MP4',
          'Convert AVI to MP4',
          'Convert MP4 to MP3',
          'Convert Video Format',
          'Video To Audio',
          'Extract Audio',
          'Resize Video',
          'Compress Video',
          'Get Video Info',
          'Supported Formats',
        ],
      },
      {
        'id': 'audio_conversion',
        'name': 'Audio Conversion',
        'description': 'Convert and process audio files',
        'icon': Icons.audiotrack_outlined,
        'category': 'Media Conversion',
        'tools': [
          'Convert MP4 to MP3', // This refers to audio_conversion id tool, so routing will use audio category id.
          'Convert WAV to MP3',
          'Convert FLAC to MP3',
          'Convert MP3 to WAV',
          'Convert FLAC to WAV',
          'Convert WAV to FLAC',
          'Convert Audio Format',
          'Normalize Audio',
          'Trim Audio',
          'Get Audio Info',
          'Supported Audio Formats',
        ],

      },
      {
        'id': 'subtitle_conversion',
        'name': 'Subtitle Conversion',
        'description': 'Convert and edit subtitle files',
        'icon': Icons.subtitles_outlined,
        'category': 'Media Conversion',
        'tools': [
          'AI: Translate SRT',
          'Convert SRT to CSV',
          'Convert SRT to Excel',
          'Convert SRT to Text',
          'Convert SRT to VTT',
          'Convert VTT to Text',
          'Convert VTT to SRT',
          'Convert CSV to SRT',
          'Convert Excel to SRT',
        ],
      },
      {
        'id': 'text_conversion',
        'name': 'Text Conversion',
        'description': 'Convert and process text files',
        'icon': Icons.text_fields,
        'category': 'Text Processing',
        'tools': [
          'Convert Word to Text',
          'Convert PowerPoint to Text',
          'Convert PDF to Text',
          'Convert SRT to Text',
          'Convert VTT to Text',
        ],
      },

      {
        'id': 'ebook_conversion',
        'name': 'eBook Conversion',
        'description': 'Convert e-book formats',
        'icon': Icons.menu_book_outlined,
        'category': 'Document Conversion',
        'tools': [
          'Convert Markdown to ePUB',
          'Convert ePUB to MOBI',
          'Convert ePUB to AZW',
          'Convert MOBI to ePUB',
          'Convert MOBI to AZW',
          'Convert AZW to ePUB',
          'Convert AZW to MOBI',
          'Convert ePUB to PDF',
          'Convert MOBI to PDF',
          'Convert AZW to PDF',
          'Convert AZW3 to PDF',
          'Convert FB2 to PDF',
          'Convert FBZ to PDF',
          'Convert PDF to ePUB',
          'Convert PDF to MOBI',
          'Convert PDF to AZW',
          'Convert PDF to AZW3',
          'Convert PDF to FB2',
          'Convert PDF to FBZ',
        ],
      },

      {
        'id': 'file_formatter',
        'name': 'File Formatter',
        'description': 'Format, Validate, Minify code files',
        'icon': Icons.code,
        'category': 'Developer Tools',
        'tools': [
          'Format JSON',
          'Validate JSON',
          'Validate XML',
          'Validate XSD',
          'Minify JSON',
          'Format XML',
          'Get JSON Schema Info',
          'Supported File Formats',
        ],
      },
    ]);
  }

  void _startAnimations() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onToolSelected(Map<String, dynamic> tool) {
    final toolsList = List<String>.from(tool['tools'] as List);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CategoryToolsPage(
          id: tool['id'] as String,
          name: tool['name'] as String,
          description: tool['description'] as String,
          icon: tool['icon'] as IconData,
          tools: toolsList,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      drawer: const CustomDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildBody(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'All Tools',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
      actions: const [],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildToolsGrid()],
      ),
    );
  }

  Widget _buildToolsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.build_outlined,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Available Tools',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_allTools.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _allTools.length,
          itemBuilder: (context, index) {
            final tool = _allTools[index];
            return _buildToolCard(tool, index);
          },
        ),
      ],
    );
  }

  Widget _buildToolCard(Map<String, dynamic> tool, int index) {
    return GestureDetector(
          onTap: () => _onToolSelected(tool),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.backgroundCard, AppColors.backgroundSurface],
              ),
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        tool['icon'] as IconData,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          tool['name'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    // Description removed to prevent overflow per request
                  ],
                ),
              ),
            ),
          ),
        )
        .animate(delay: (index * 50).ms)
        .slideX(begin: 0.3, duration: 600.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 600.ms);
  }
}
