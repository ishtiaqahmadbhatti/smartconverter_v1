import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildAppHeader(),
                const SizedBox(height: 30),
                _buildIntroSection(),
                const SizedBox(height: 30),
                _buildStatsSection(),
                const SizedBox(height: 30),
                _buildFeatureList(),
                const SizedBox(height: 40),
                _buildDeveloperInfo(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 50,
      leading: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          iconSize: 20,
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: const Text(
        'About',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAppHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.folder_outlined,
                size: 110,
                color: Colors.white,
              ),
              Positioned(
                top: 40,
                child: const Icon(
                  Icons.sync,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Smart Converter',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryBlue.withOpacity(0.3),
            ),
          ),
          child: Text(
            'Version ${AppStrings.appVersion}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, duration: 600.ms);
  }

  Widget _buildIntroSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.1),
        ),
      ),
      child: const Text(
        'Smart Converter is your ultimate all-in-one file processing companion. '
        'Easily convert, edit, and manage documents, images, audio, and video files '
        'with our powerful suite of tools designed for speed and efficiency.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          height: 1.6,
          color: AppColors.textSecondary,
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, duration: 600.ms);
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '14+',
            'Categories',
            Icons.category_outlined,
            AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            '90+',
            'Tools',
            Icons.handyman_outlined,
            AppColors.secondaryGreen,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, duration: 600.ms);
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureList() {
    final categories = [
      {
        'title': 'PDF Tools',
        'icon': Icons.picture_as_pdf,
        'tools': [
          'Merge, Split, Compress PDF',
          'Remove/Extract Pages',
          'Rotate, Crop, Add Watermark',
          'Protect, Unlock, Repair PDF',
          'Compare PDFs, Get Metadata',
          'Convert to Word, Excel, CSV',
          'Convert to JPG, PNG, SVG',
          'Convert to HTML, Text, JSON'
        ]
      },
      {
        'title': 'Image Tools',
        'icon': Icons.image,
        'tools': [
          'Convert between JPG, PNG, WebP',
          'Support for AVIF, TIFF, BMP, HEIC',
          'Convert SVG to Raster',
          'Website/HTML to Image',
          'Remove EXIF Data'
        ]
      },
      {
        'title': 'Video Tools',
        'icon': Icons.movie,
        'tools': [
          'Convert MOV, MKV, AVI to MP4',
          'Video to MP3 (Extract Audio)',
          'Resize & Compress Video',
          'Get Video Information'
        ]
      },
      {
        'title': 'Audio Tools',
        'icon': Icons.music_note,
        'tools': [
          'Convert WAV, FLAC to MP3',
          'Convert MP3 to WAV',
          'Trim & Normalize Audio',
          'Get Audio Information'
        ]
      },
      {
        'title': 'Office Documents',
        'icon': Icons.description,
        'tools': [
          'Word, PowerPoint to PDF/HTML',
          'Excel to PDF, CSV, XML, HTML',
          'OpenOffice (ODS) Support',
          'Extract Text from Docs'
        ]
      },
      {
        'title': 'E-Book Tools',
        'icon': Icons.menu_book,
        'tools': [
          'Convert ePUB, MOBI, AZW to PDF',
          'Convert PDF to eBook Formats',
          'Support for FB2, FBZ, AZW3'
        ]
      },
      {
        'title': 'OCR (Text Recognition)',
        'icon': Icons.document_scanner,
        'tools': [
          'Image (PNG/JPG) to Text/PDF',
          'PDF to Text',
          'Extract Text from Scans'
        ]
      },
      {
        'title': 'Data Conversion (CSV/JSON/XML)',
        'icon': Icons.data_object,
        'tools': [
          'Convert JSON to CSV, Excel, XML',
          'Convert CSV to JSON, Excel, XML',
          'Convert XML to JSON, CSV, Excel',
          'JSON/XML Formatter & Validator',
          'Minify JSON',
          'AI: PDF/Image to JSON/CSV'
        ]
      },
      {
        'title': 'Subtitle Tools',
        'icon': Icons.subtitles,
        'tools': [
          'AI Translate Subtitles',
          'Convert SRT <-> VTT',
          'Convert Subtitles to CSV/Excel',
          'Convert Subtitles to Text'
        ]
      },
      {
        'title': 'Website Tools',
        'icon': Icons.public,
        'tools': [
          'Website/HTML to PDF',
          'Website/HTML to Image',
          'Convert HTML Tables to CSV'
        ]
      }
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            'Explore Our Capabilities:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final category = categories[index];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                ),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      category['icon'] as IconData,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    category['title'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (category['tools'] as List<String>)
                            .map((tool) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline,
                                        size: 16,
                                        color: AppColors.secondaryGreen,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          tool,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: (400 + (index * 50)).ms).slideX(begin: 0.2, duration: 400.ms).fadeIn();
          },
        ),
      ],
    );
  }

  Widget _buildDeveloperInfo() {
    return Column(
      children: [
        Container(
          height: 3,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppColors.secondaryGradient,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondaryGreen.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.secondaryGradient.createShader(bounds),
          child: const Text(
            'PROUDLY BUILT BY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: const Text(
            'TechMindsForge',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(
              duration: 2000.ms,
              color: AppColors.textPrimary.withOpacity(0.5),
              angle: 0.8, // Slight angle to make it look like a passing wave
            )
            .effect(
              duration: 2000.ms,
              curve: Curves.easeInOut,
            ), // smooth loop
        const SizedBox(height: 20),
        _buildSocialLinks(),
        const SizedBox(height: 50),
        Text(
          '© ${DateTime.now().year} ALL RIGHTS RESERVED',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1000.ms);
  }

  Widget _buildSocialLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(FontAwesomeIcons.globe, 'Website', () {}, glowColor: AppColors.secondaryCyan),
        const SizedBox(width: 20),
        _buildSocialIcon(FontAwesomeIcons.facebookF, 'Facebook', () {}, glowColor: const Color(0xFF1877F2)),
        const SizedBox(width: 20),
        _buildSocialIcon(FontAwesomeIcons.instagram, 'Instagram', () {}, glowColor: const Color(0xFFE1306C)),
        const SizedBox(width: 20),
        _buildSocialIcon(FontAwesomeIcons.youtube, 'YouTube', () {}, glowColor: const Color(0xFFFF0000)),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String label, VoidCallback onTap, {Color? glowColor}) {
    final Color effectiveGlowColor = glowColor ?? AppColors.primaryBlue;
    
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15), // Rounded square for modern look
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
             effectiveGlowColor.withOpacity(0.6),
             effectiveGlowColor.withOpacity(0.1),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: effectiveGlowColor.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2), // Create thin, glowing border effect
        decoration: BoxDecoration(
          color: AppColors.backgroundCard, // Dark inner background
          borderRadius: BorderRadius.circular(13),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: onTap,
            child: Center(
              child: FaIcon(
                icon, 
                size: 22, 
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    )
    .animate(onPlay: (controller) => controller.repeat(reverse: true))
    .scale(
      begin: const Offset(1.0, 1.0),
      end: const Offset(1.05, 1.05),
      duration: 2000.ms,
      curve: Curves.easeInOut,
    ) // Subtle breathing effect
    .shimmer(
      delay: 2000.ms,
      duration: 1500.ms,
      color: Colors.white.withOpacity(0.4),
    );
  }
}
