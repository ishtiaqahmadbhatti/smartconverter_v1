import '../../../app_modules/imports_module.dart';

class AiTranslateSrtPage extends StatefulWidget {
  const AiTranslateSrtPage({super.key});

  @override
  State<AiTranslateSrtPage> createState() => _AiTranslateSrtPageState();
}

class _AiTranslateSrtPageState extends State<AiTranslateSrtPage> 
    with AdHelper, ConversionMixin {
  
  @override
  final ConversionService service = ConversionService();
  
  @override
  final TextEditingController fileNameController = TextEditingController();
  
  @override
  final ConversionModel model = ConversionModel(
    statusMessage: 'Select an SRT file to begin.',
  );

  List<String> _supportedLanguages = [];
  String? _selectedTargetLanguage;
  bool _isLoadingLanguages = true;

  @override
  String get fileTypeLabel => 'SRT';
  
  @override
  List<String> get allowedExtensions => ['srt'];
  
  @override
  String get conversionToolName => 'AI Translate SRT';
  
  @override
  Future<Directory> get saveDirectory => FileManager.getSrtTranslateDirectory();

  @override
  void initState() {
    super.initState();
    fileNameController.addListener(handleFileNameChange);
    _loadSupportedLanguages();
  }

  @override
  void dispose() {
    fileNameController
      ..removeListener(handleFileNameChange)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadSupportedLanguages() async {
    try {
      final languages = await service.getSupportedLanguages();
      if (mounted) {
        setState(() {
          languages.sort();
          _supportedLanguages = languages;
          _isLoadingLanguages = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading languages: $e');
      if (mounted) {
        setState(() {
          _isLoadingLanguages = false;
        });
      }
    }
  }
  
  @override
  void updateSuggestedFileName() {
    if (model.selectedFile == null) {
      setState(() {
        model.suggestedBaseName = null;
        if (!model.fileNameEdited) {
          fileNameController.clear();
        }
      });
      return;
    }

    final baseName = basenameWithoutExtension(model.selectedFile!.path);
    final sanitized = sanitizeBaseName(baseName);
    final langSuffix = _selectedTargetLanguage != null ? '_$_selectedTargetLanguage' : '';
    
    setState(() {
      model.suggestedBaseName = '$sanitized$langSuffix';
      if (!model.fileNameEdited) {
        fileNameController.text = model.suggestedBaseName!;
      }
    });
  }

  @override
  void resetForNewConversion({String? customStatus}) {
    super.resetForNewConversion(customStatus: customStatus);
    setState(() {
      _selectedTargetLanguage = null;
    });
  }

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) {
    if (_selectedTargetLanguage == null) {
      throw Exception('Target language not selected');
    }
    return service.translateSrt(
      file!,
      targetLanguage: _selectedTargetLanguage!,
      outputFilename: outputName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Translate SRT', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConversionHeaderCardWidget(
                      title: 'AI Translate SRT',
                      description: 'Translate SRT subtitles to other languages using AI',
                      iconSource: Icons.translate,
                      iconTarget: Icons.language,
                    ),
                    const SizedBox(height: 16),

                    ConversionActionButtonWidget(
                      isFileSelected: model.selectedFile != null,
                      onPickFile: pickFile,
                      onReset: resetForNewConversion,
                      isConverting: model.isConverting,
                      buttonText: 'Select SRT File',
                    ),
                    const SizedBox(height: 24),

                    if (model.selectedFile != null) ...[
                      ConversionSelectedFileCardWidget(
                        fileName: basename(model.selectedFile!.path),
                        fileSize: formatBytes(model.selectedFile!.lengthSync()),
                        fileIcon: Icons.subtitles,
                      ),
                      const SizedBox(height: 16),
                      
                      // Language Dropdown
                      _buildLanguageDropdown(),
                      const SizedBox(height: 16),

                      ConversionFileNameFieldWidget(
                        controller: fileNameController,
                      ),
                      const SizedBox(height: 24),
                      
                      ConversionConvertButtonWidget(
                        isConverting: model.isConverting,
                        onConvert: convert,
                        buttonText: 'Translate SRT',
                        isEnabled: !model.isConverting && _selectedTargetLanguage != null,
                      ),
                      const SizedBox(height: 24),
                    ],

                    ConversionStatusDisplayWidget(
                        message: model.statusMessage,
                        isConverting: model.isConverting,
                        isSuccess: model.conversionResult != null,
                    ),
                    
                    if (model.conversionResult != null) ...[
                      const SizedBox(height: 20),
                      if (model.savedFilePath == null)
                        ConversionFileSaveCardWidget(
                          fileName: model.conversionResult!.fileName,
                          isSaving: model.isSaving,
                          onSave: saveResult,
                          title: 'Translated File Ready',
                        )
                      else
                        ConversionResultCardWidget(
                            savedFilePath: model.savedFilePath!,
                            onShare: shareFile,
                        ),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBannerAd(),
    );
  }

  Widget _buildLanguageDropdown() {
    if (_isLoadingLanguages) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTargetLanguage,
          hint: const Text(
            'Select Target Language',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          isExpanded: true,
          dropdownColor: AppColors.backgroundSurface,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryBlue),
          style: const TextStyle(color: AppColors.textPrimary),
          items: _supportedLanguages.map((String lang) {
            return DropdownMenuItem<String>(
              value: lang,
              child: Text(lang.toUpperCase()),
            );
          }).toList(),
          onChanged: model.isConverting ? null : (String? newValue) {
            setState(() {
              _selectedTargetLanguage = newValue;
              updateSuggestedFileName();
            });
          },
        ),
      ),
    );
  }
}

