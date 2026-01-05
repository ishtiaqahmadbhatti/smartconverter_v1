import '../../../app_modules/imports_module.dart';


class ImageResizePage extends StatefulWidget {
  const ImageResizePage({super.key});

  @override
  State<ImageResizePage> createState() => _ImageResizePageState();
}

class _ImageResizePageState extends State<ImageResizePage> with AdHelper, ConversionMixin {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final ConversionModel _model = ConversionModel(statusMessage: 'Select an image to resize.');
  bool maintainAspectRatio = true;
  double? activeAspectRatio;


  @override
  void initState() {
    super.initState();
    _fileNameController.addListener(_handleFileNameChange);
    _service.initialize();
  }

  @override
  void dispose() {
    _fileNameController.removeListener(_handleFileNameChange);
    _fileNameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _handleFileNameChange() {
    // handled by mixin if needed
  }

  // Mixin overrides
  @override
  ConversionModel get model => _model;
  @override
  TextEditingController get fileNameController => _fileNameController;
  @override
  ConversionService get service => _service;
  @override
  String get conversionToolName => 'Image Resize';
  @override
  String get fileTypeLabel => 'Image';
  @override
  String get targetExtension => 'jpg'; 
  @override
  List<String> get allowedExtensions => ['jpg', 'jpeg', 'png', 'webp', 'tiff'];

  @override
  Future<void> pickFile({String type = 'custom'}) async {
    await super.pickFile(type: type);
    if (model.selectedFile != null) {
      try {
        final decodedImage = await decodeImageFromList(model.selectedFile!.readAsBytesSync());
        _widthController.text = decodedImage.width.toString();
        _heightController.text = decodedImage.height.toString();
        activeAspectRatio = decodedImage.width / decodedImage.height;
      } catch (e) {
        // Fallback or ignore if not decodable
        activeAspectRatio = null;
      }
    }
  }

  @override
  Future<Directory> get saveDirectory async {
    final root = await FileManager.getSmartConverterDirectory();
    final imageRoot = Directory('${root.path}/ImageConversion');
    if (!await imageRoot.exists()) await imageRoot.create(recursive: true);
    
    final toolDir = Directory('${imageRoot.path}/resize');
    if (!await toolDir.exists()) await toolDir.create(recursive: true);
    return toolDir;
  }

  @override
  Future<ImageFormatConversionResult?> performConversion(File? file, String? outputName) async {
    if (file == null) throw Exception('File is null');

    final width = int.tryParse(_widthController.text);
    final height = int.tryParse(_heightController.text);

    if (width == null && height == null) {
      throw Exception('Please enter at least one dimension (Width or Height).');
    }

    final adWatched = await showRewardedAdGate(toolName: 'Image Resize');
    if (!adWatched) {
      throw Exception('Ad required to proceed.');
    }

    return await service.resizeImage(
      file, 
      width: width, 
      height: height, 
      outputFilename: outputName
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Image Resize',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        leading: BackButton(color: AppColors.textPrimary),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ConversionHeaderCardWidget(
                  title: 'Resize Image',
                  description: 'Change the dimensions of your image files.',
                  iconTarget: Icons.aspect_ratio,
                  iconSource: Icons.image,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(type: 'image'),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select Image',
                ),
                const SizedBox(height: 16),
                if (model.selectedFile != null) ...[
                   ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    fileIcon: Icons.image,
                    onRemove: resetForNewConversion,
                  ),
                  const SizedBox(height: 16),
                  
                  // Dimensions Inputs
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _widthController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Width',
                            labelStyle: TextStyle(color: AppColors.primaryBlue.withOpacity(0.8)),
                            filled: true,
                            fillColor: AppColors.backgroundSurface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onChanged: (val) {
                             if (!maintainAspectRatio || activeAspectRatio == null) return;
                             if (val.isEmpty) return;
                             final w = int.tryParse(val);
                             if (w != null) {
                                final h = (w / activeAspectRatio!).round();
                                _heightController.text = h.toString();
                             }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Height',
                            labelStyle: TextStyle(color: AppColors.primaryBlue.withOpacity(0.8)),
                            filled: true,
                            fillColor: AppColors.backgroundSurface,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onChanged: (val) {
                             if (!maintainAspectRatio || activeAspectRatio == null) return;
                             if (val.isEmpty) return;
                             final h = int.tryParse(val);
                             if (h != null) {
                                final w = (h * activeAspectRatio!).round();
                                _widthController.text = w.toString();
                             }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: maintainAspectRatio,
                    onChanged: (val) {
                      setState(() {
                         maintainAspectRatio = val ?? true;
                         if (maintainAspectRatio) {
                            // Reset ratio based on current values or original file
                            final w = int.tryParse(_widthController.text);
                            final h = int.tryParse(_heightController.text);
                            if (w != null && h != null && h != 0) {
                               activeAspectRatio = w / h;
                            }
                         }
                      });
                    },
                    title: const Text('Maintain Aspect Ratio', style: TextStyle(color: Colors.white70)),
                    activeColor: AppColors.primaryBlue,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),

                  const SizedBox(height: 16),
                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    labelText: 'Output file name (optional)',
                    extensionLabel: 'Original extension preserved',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Resize Image',
                  ),
                ],
                const SizedBox(height: 16),
                ConversionStatusWidget(
                  statusMessage: model.statusMessage,
                  isConverting: model.isConverting,
                  conversionResult: model.conversionResult,
                ),
                if (model.conversionResult != null) ...[
                  const SizedBox(height: 20),
                  if (model.savedFilePath == null)
                    ConversionFileSaveCardWidget(
                      fileName: model.conversionResult!.fileName,
                      isSaving: model.isSaving,
                      onSave: saveResult,
                      title: 'Resized Image Ready',
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
