import '../../../app_modules/imports_module.dart';

class TrimAudioPage extends StatefulWidget {
  const TrimAudioPage({super.key});

  @override
  State<TrimAudioPage> createState() => _TrimAudioPageState();
}

class _TrimAudioPageState extends State<TrimAudioPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select an audio file to trim.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  final TextEditingController _startController = TextEditingController(text: '0.0');
  final TextEditingController _endController = TextEditingController(text: '10.0');

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Trim Audio';

  @override
  String get fileTypeLabel => 'Audio';

  @override
  String get targetExtension => 'wav';

  @override
  List<String> get allowedExtensions => ['mp3', 'wav', 'flac', 'aac', 'ogg', 'wma', 'm4a'];

  @override
  Future<Directory> get saveDirectory => FileManager.getTrimAudioDirectory();
  
  @override
  Future<dynamic> performConversion(File? file, String? outputName) {
    if (file == null) throw Exception('File is null');
    return service.convertEbook(
        file, 
        outputFilename: outputName, 
        endpoint: ApiConfig.audioTrimEndpoint,
        outputExt: targetExtension,
        extraParams: {
          'start_time': _startController.text,
          'end_time': _endController.text,
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
                  description: 'Trim specific parts of your audio files.',
                  sourceIcon: Icons.audiotrack,
                  destinationIcon: Icons.cut,
                ),
                const SizedBox(height: 20),
                
                 // Time Inputs
                 Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _startController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Start Time (sec)',
                          filled: true,
                          fillColor: AppColors.backgroundSurface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                        ),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _endController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'End Time (sec)',
                          filled: true,
                          fillColor: AppColors.backgroundSurface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                        ),
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // File Selection
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select Audio File',
                ),
                const SizedBox(height: 16),

                if (model.selectedFile != null)
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: getSafeFileSize(model.selectedFile!),
                    fileIcon: Icons.audiotrack,
                    onRemove: resetForNewConversion,
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
                    buttonText: 'Trim Audio By Time',
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
                      title: 'Trimmed File Is Ready',
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
