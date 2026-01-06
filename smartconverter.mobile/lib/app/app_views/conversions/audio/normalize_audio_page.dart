import '../../../app_modules/imports_module.dart';

class NormalizeAudioPage extends StatefulWidget {
  const NormalizeAudioPage({super.key});

  @override
  State<NormalizeAudioPage> createState() => _NormalizeAudioPageState();
}

class _NormalizeAudioPageState extends State<NormalizeAudioPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select an audio file to normalize.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  double _targetDb = -20.0;

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Normalize Audio';

  @override
  String get fileTypeLabel => 'Audio';

  @override
  String get targetExtension => 'wav';

  @override
  List<String> get allowedExtensions => ['mp3', 'wav', 'flac', 'aac', 'ogg', 'wma', 'm4a'];

  @override
  Future<Directory> get saveDirectory => FileManager.getNormalizeAudioDirectory();
  
  @override
  Future<dynamic> performConversion(File? file, String? outputName) {
    if (file == null) throw Exception('File is null');
    return service.convertEbook(
        file, 
        outputFilename: outputName, 
        endpoint: ApiConfig.audioNormalizeEndpoint,
        outputExt: targetExtension,
        extraParams: {
          'target_dBFS': _targetDb.toString(),
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
                  description: 'Normalize the volume of your audio files.',
                  sourceIcon: Icons.graphic_eq,
                  destinationIcon: Icons.volume_up,
                ),
                const SizedBox(height: 20),
                
                // DB Slider
                 Container(
                   decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
                  ),
                   padding: const EdgeInsets.all(16),
                   child: Column(
                     children: [
                       const Text(
                          'Target Level (dBFS)',
                          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: _targetDb,
                          min: -50.0,
                          max: 0.0,
                          divisions: 50,
                          label: '${_targetDb.toStringAsFixed(1)} dB',
                          activeColor: AppColors.primaryBlue,
                          inactiveColor: AppColors.backgroundSurface,
                          onChanged: (val) {
                            setState(() => _targetDb = val);
                          },
                        ),
                        Text(
                          'Selected level: ${_targetDb.toStringAsFixed(1)} dB',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                     ],
                   ),
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
                    buttonText: 'Normalize Audio',
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
                      title: 'Normalized File Is Ready',
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
