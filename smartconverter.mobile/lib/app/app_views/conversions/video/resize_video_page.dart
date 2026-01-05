import '../../../app_modules/imports_module.dart';

class ResizeVideoPage extends StatefulWidget {
  const ResizeVideoPage({super.key});

  @override
  State<ResizeVideoPage> createState() => _ResizeVideoPageState();
}

class _ResizeVideoPageState extends State<ResizeVideoPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select a video file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String _selectedQuality = 'medium';
  final List<String> _qualities = ['low', 'medium', 'high', 'ultra'];

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Resize Video';

  @override
  String get fileTypeLabel => 'Video';

  @override
  String get targetExtension => 'mp4';

  @override
  List<String> get allowedExtensions => ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', 'webm', 'm4v', '3gp', 'ogv'];

  @override
  Future<Directory> get saveDirectory => FileManager.getResizeVideoDirectory();

  @override
  Future<dynamic> performConversion(File? file, String? outputName) {
    if (file == null) throw Exception('File is null');
    return service.convertEbook(
        file, 
        outputFilename: outputName, 
        endpoint: ApiConfig.videoResizeEndpoint,
        outputExt: targetExtension,
        extraParams: {
          'width': _widthController.text.trim(),
          'height': _heightController.text.trim(),
          'quality': _selectedQuality,
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          conversionToolName,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ConversionHeaderCardWidget(
                  title: conversionToolName,
                  description: 'Resize video dimensions and adjust quality.',
                  icon: Icons.aspect_ratio_outlined,
                ),
                const SizedBox(height: 20),
                
                // File Selection
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select Video File',
                ),
                const SizedBox(height: 16),

                if (model.selectedFile != null)
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: getSafeFileSize(model.selectedFile!),
                    fileIcon: Icons.movie,
                    onRemove: resetForNewConversion,
                  ),
                 const SizedBox(height: 20),

                 // Dimensions Inputs
                 Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _widthController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Width (px)',
                            hintText: 'e.g. 1280',
                            filled: true,
                            fillColor: AppColors.backgroundSurface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.horizontal_rule, color: AppColors.primaryBlue),
                             hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
                             labelStyle: const TextStyle(color: AppColors.textSecondary),
                          ),
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Height (px)',
                            hintText: 'e.g. 720',
                            filled: true,
                            fillColor: AppColors.backgroundSurface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.vertical_align_center, color: AppColors.primaryBlue),
                            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.7)),
                            labelStyle: const TextStyle(color: AppColors.textSecondary),
                          ),
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),

                 // Quality Dropdown
                 Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedQuality,
                        isExpanded: true,
                        dropdownColor: AppColors.backgroundSurface,
                        icon: const Icon(Icons.high_quality, color: AppColors.primaryBlue),
                        items: _qualities.map((quality) {
                          return DropdownMenuItem(
                            value: quality,
                            child: Text(
                              'Quality: ${quality[0].toUpperCase() + quality.substring(1)}',
                              style: const TextStyle(color: AppColors.textPrimary),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedQuality = value);
                          }
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Filename Input
                if (model.selectedFile != null)
                  ConversionFileNameFieldWidget(
                    controller: fileNameController, 
                    suggestedName: model.suggestedBaseName,
                    extensionLabel: '.$targetExtension extension is added automatically',
                  ),
                
                // Action Button
                if (model.selectedFile != null) ...[
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Resize Video',
                  ),
                ],

                const SizedBox(height: 16),
                ConversionStatusWidget(
                  statusMessage: model.statusMessage,
                  isConverting: model.isConverting,
                  conversionResult: model.conversionResult,
                ),
                
                // Success Card
                if (model.conversionResult != null) ...[
                  const SizedBox(height: 20),
                  if (model.savedFilePath == null)
                    ConversionFileSaveCardWidget(
                      fileName: model.conversionResult!.fileName,
                      isSaving: model.isSaving,
                      onSave: saveResult,
                      title: 'Resized Video Ready',
                    )
                  else
                    ConversionResultCardWidget(
                      savedFilePath: model.savedFilePath!,
                      onShare: shareFile,
                    ),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBannerAd(),
    );
  }
}
