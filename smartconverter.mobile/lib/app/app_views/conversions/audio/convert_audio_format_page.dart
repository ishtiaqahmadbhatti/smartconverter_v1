import '../../../app_modules/imports_module.dart';

class ConvertAudioFormatPage extends StatefulWidget {
  const ConvertAudioFormatPage({super.key});

  @override
  State<ConvertAudioFormatPage> createState() => _ConvertAudioFormatPageState();
}

class _ConvertAudioFormatPageState extends State<ConvertAudioFormatPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select an audio file and target format.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  String _selectedFormat = 'mp3';
  final List<String> _formats = ['mp3', 'wav', 'flac', 'aac', 'ogg', 'wma', 'm4a'];

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Convert Audio Format';

  @override
  String get fileTypeLabel => 'Audio';

  @override
  String get targetExtension => _selectedFormat;

  @override
  List<String> get allowedExtensions => ['mp3', 'wav', 'flac', 'aac', 'ogg', 'wma', 'm4a'];

  @override
  Future<Directory> get saveDirectory => FileManager.getConvertAudioFormatDirectory();
  
  @override
  Future<dynamic> performConversion(File? file, String? outputName) {
    if (file == null) throw Exception('File is null');
    return service.convertEbook(
        file, 
        outputFilename: outputName, 
        endpoint: ApiConfig.audioConvertFormatEndpoint,
        outputExt: targetExtension,
        extraParams: {
          'output_format': _selectedFormat,
          'quality': 'medium',
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
                  description: 'Convert between various audio formats.',
                  sourceIcon: Icons.audiotrack,
                  destinationIcon: Icons.compare_arrows,
                ),
                const SizedBox(height: 20),
                
                // Format Selection
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
                      items: _formats.map((format) {
                        return DropdownMenuItem(
                          value: format,
                          child: Text(
                            'Convert to ${format.toUpperCase()}',
                            style: const TextStyle(color: AppColors.textPrimary),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedFormat = newValue;
                          });
                        }
                      },
                    ),
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
                    buttonText: 'Convert Audio',
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
                      title: 'Converted File Is Ready',
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
