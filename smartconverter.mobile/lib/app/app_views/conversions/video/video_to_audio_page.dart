import '../../../app_modules/imports_module.dart';

class VideoToAudioPage extends StatefulWidget {
  const VideoToAudioPage({super.key});

  @override
  State<VideoToAudioPage> createState() => _VideoToAudioPageState();
}

class _VideoToAudioPageState extends State<VideoToAudioPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select a video file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  String _selectedFormat = 'mp3';
  final List<String> _formats = ['mp3', 'wav', 'aac', 'm4a', 'flac'];

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Video To Audio';

  @override
  String get fileTypeLabel => 'Video';

  @override
  String get targetExtension => _selectedFormat;

  @override
  List<String> get allowedExtensions => ['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', 'webm', 'm4v', '3gp', 'ogv'];

  @override
  Future<Directory> get saveDirectory => FileManager.getVideoToAudioDirectory();

  @override
  Future<dynamic> performConversion(File? file, String? outputName) {
    if (file == null) throw Exception('File is null');
    return service.convertEbook(
        file, 
        outputFilename: outputName, 
        endpoint: ApiConfig.videoToAudioEndpointNew,
        outputExt: targetExtension,
        extraParams: {
          'output_format': _selectedFormat,
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
                  description: 'Convert video files to audio formats like MP3, WAV, AAC, etc.',
                  icon: Icons.audiotrack_outlined,
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

                 // Format Dropdown
                 Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Output Format', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 4),
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
                            value: _selectedFormat,
                            isExpanded: true,
                            dropdownColor: AppColors.backgroundSurface,
                            icon: const Icon(Icons.audiotrack, color: AppColors.primaryBlue),
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
                    buttonText: 'Convert to ${targetExtension.toUpperCase()}',
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
                      title: 'Audio File Ready',
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
