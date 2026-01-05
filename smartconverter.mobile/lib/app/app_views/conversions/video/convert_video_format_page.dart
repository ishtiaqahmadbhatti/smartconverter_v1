import '../../../app_modules/imports_module.dart';

class ConvertVideoFormatPage extends StatefulWidget {
  const ConvertVideoFormatPage({super.key});

  @override
  State<ConvertVideoFormatPage> createState() => _ConvertVideoFormatPageState();
}

class _ConvertVideoFormatPageState extends State<ConvertVideoFormatPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select a video file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  String _selectedFormat = 'mp4';
  String _selectedQuality = 'medium';
  final List<String> _formats = [
    'mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', 'webm', 'm4v', '3gp', 'ogv'
  ];
  final List<String> _qualities = ['low', 'medium', 'high', 'ultra'];

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Convert Video Format';

  @override
  String get fileTypeLabel => 'Video';

  @override
  String get targetExtension => _selectedFormat;

  @override
  List<String> get allowedExtensions => ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', 'webm', 'm4v', '3gp', 'ogv'];

  @override
  Future<Directory> get saveDirectory => FileManager.getConvertVideoFormatDirectory();

  @override
  Future<dynamic> performConversion(File? file, String? outputName) {
    if (file == null) throw Exception('File is null');
    return service.convertEbook(
        file, 
        outputFilename: outputName, 
        endpoint: ApiConfig.videoConvertFormatEndpoint,
        outputExt: targetExtension,
        extraParams: {
          'output_format': _selectedFormat,
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
                  description: 'Convert your video to different formats and qualities.',
                  icon: Icons.movie_creation_outlined,
                ),
                const SizedBox(height: 20),
                
                // File Selection Button (Main Action)
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select Video File',
                ),
                const SizedBox(height: 16),

                // Selected File Display
                if (model.selectedFile != null)
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: getSafeFileSize(model.selectedFile!),
                    fileIcon: Icons.movie,
                    onRemove: resetForNewConversion,
                  ),
                 const SizedBox(height: 20),

                 // Dropdowns
                 Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Format', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedFormat,
                                  isExpanded: true,
                                  dropdownColor: AppColors.backgroundSurface,
                                  icon: const Icon(Icons.movie_creation, color: AppColors.primaryBlue),
                                  items: _formats.map((format) {
                                    return DropdownMenuItem(
                                      value: format,
                                      child: Text(
                                        format.toUpperCase(),
                                        style: const TextStyle(color: AppColors.textPrimary),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedFormat = value);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Quality', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                             const SizedBox(height: 4),
                            Container(
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
                                        quality[0].toUpperCase() + quality.substring(1),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),

                // Filename Input
                if (model.selectedFile != null)
                  ConversionFileNameFieldWidget(
                    controller: fileNameController, 
                    suggestedName: model.suggestedBaseName,
                    extensionLabel: '.$targetExtension extension is added automatically',
                  ),
                
                // Convert Button
                if (model.selectedFile != null) ...[
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to ${targetExtension.toUpperCase()}',
                  ),
                ],

                const SizedBox(height: 16),
                ConversionStatusWidget(
                  statusMessage: model.statusMessage,
                  isConverting: model.isConverting,
                  conversionResult: model.conversionResult,
                ),

                // Success or Save Card
                if (model.conversionResult != null) ...[
                  const SizedBox(height: 20),
                  if (model.savedFilePath == null)
                    ConversionFileSaveCardWidget(
                      fileName: model.conversionResult!.fileName,
                      isSaving: model.isSaving,
                      onSave: saveResult,
                      title: 'Converted File Ready',
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
