import '../../../app_modules/imports_module.dart';

class CompressVideoPage extends StatefulWidget {
  const CompressVideoPage({super.key});

  @override
  State<CompressVideoPage> createState() => _CompressVideoPageState();
}

class _CompressVideoPageState extends State<CompressVideoPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select a video file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  String _selectedLevel = 'medium';
  final List<String> _levels = ['low', 'medium', 'high', 'ultra'];

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Compress Video';

  @override
  String get fileTypeLabel => 'Video';

  @override
  String get targetExtension => 'mp4';

  @override
  List<String> get allowedExtensions => ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', 'webm', 'm4v', '3gp', 'ogv'];

  @override
  Future<Directory> get saveDirectory => FileManager.getCompressVideoDirectory();

  @override
  Future<dynamic> performConversion(File? file, String? outputName) {
    if (file == null) throw Exception('File is null');
    return service.convertEbook(
        file, 
        outputFilename: outputName, 
        endpoint: ApiConfig.videoCompressEndpoint,
        outputExt: targetExtension,
        extraParams: {
          'compression_level': _selectedLevel,
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
                  description: 'Reduce video file size while maintaining acceptable quality.',
                  icon: Icons.compress_outlined,
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

                 // Level Dropdown
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
                        value: _selectedLevel,
                        isExpanded: true,
                        dropdownColor: AppColors.backgroundSurface,
                        icon: const Icon(Icons.compress, color: AppColors.primaryBlue),
                        items: _levels.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(
                              'Compression: ${level[0].toUpperCase() + level.substring(1)}',
                              style: const TextStyle(color: AppColors.textPrimary),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedLevel = value);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Higher compression means smaller file size but lower quality.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
                    buttonText: 'Compress Video',
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
                      title: 'Compressed Video Ready',
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
