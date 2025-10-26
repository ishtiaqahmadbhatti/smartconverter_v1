import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../models/conversion_tool.dart';

class ToolCard extends StatefulWidget {
  final ConversionTool tool;
  final VoidCallback onTap;

  const ToolCard({super.key, required this.tool, required this.onTap});

  @override
  State<ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<ToolCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimation =
        ColorTween(
          begin: AppColors.backgroundCard,
          end: AppColors.primaryBlue.withOpacity(0.2),
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildToolIcon() {
    // Check if this is a conversion tool (has ' To ' in name)
    if (widget.tool.name.contains(' To ')) {
      return _buildConversionIcon();
    } else {
      return _buildSingleIcon();
    }
  }

  Widget _buildConversionIcon() {
    final parts = widget.tool.name.split(' To ');
    if (parts.length == 2) {
      return Container(
        constraints: const BoxConstraints(maxWidth: 80, maxHeight: 40),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: _getFileTypeIcon(parts[0].trim()),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_forward,
              size: 16,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 4),
            SizedBox(
              width: 24,
              height: 24,
              child: _getFileTypeIcon(parts[1].trim()),
            ),
          ],
        ),
      );
    }
    return _buildSingleIcon();
  }

  Widget _buildSingleIcon() {
    return Text(widget.tool.icon, style: const TextStyle(fontSize: 24));
  }

  Widget _getFileTypeIcon(String fileType) {
    switch (fileType.toUpperCase()) {
      case 'PDF':
        return const Icon(
          Icons.picture_as_pdf,
          size: 20,
          color: AppColors.textPrimary,
        );
      case 'WORD':
      case 'DOC':
      case 'DOCX':
        return const Icon(
          Icons.description,
          size: 20,
          color: AppColors.textPrimary,
        );
      case 'EXCEL':
      case 'XLS':
      case 'XLSX':
        return const Icon(
          Icons.table_chart,
          size: 20,
          color: AppColors.textPrimary,
        );
      case 'POWERPOINT':
      case 'PPT':
      case 'PPTX':
        return const Icon(
          Icons.slideshow,
          size: 20,
          color: AppColors.textPrimary,
        );
      case 'JPG':
      case 'JPEG':
      case 'PNG':
        return const Icon(Icons.image, size: 20, color: AppColors.textPrimary);
      case 'HTML':
        return const Icon(
          Icons.language,
          size: 20,
          color: AppColors.textPrimary,
        );
      case 'TXT':
        return const Icon(
          Icons.text_fields,
          size: 20,
          color: AppColors.textPrimary,
        );
      default:
        return const Icon(
          Icons.insert_drive_file,
          size: 20,
          color: AppColors.textPrimary,
        );
    }
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _colorAnimation.value ?? AppColors.backgroundCard,
                          AppColors.backgroundSurface,
                        ],
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: _buildToolIcon(),
                            ),
                            const SizedBox(height: 12),
                            Flexible(
                              child: Text(
                                widget.tool.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, duration: 600.ms, curve: Curves.easeOutCubic);
  }
}

class CompactToolCard extends StatelessWidget {
  final ConversionTool tool;
  final VoidCallback onTap;

  const CompactToolCard({super.key, required this.tool, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: AppColors.cardGradient,
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(tool.icon, style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tool.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        tool.category,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.2, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}
