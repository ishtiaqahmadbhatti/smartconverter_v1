import '../../../app_modules/imports_module.dart';

class CropPdfPage extends StatefulWidget {
  const CropPdfPage({super.key});
  @override
  State<CropPdfPage> createState() => _CropPdfPageState();
}

class _CropPdfPageState extends State<CropPdfPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select a PDF file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  final TextEditingController _xController = TextEditingController(text: '0');
  final TextEditingController _yController = TextEditingController(text: '0');
  final TextEditingController _wController = TextEditingController(text: '100');
  final TextEditingController _hController = TextEditingController(text: '100');

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Crop PDF';

  @override
  String get fileTypeLabel => 'PDF';

  @override
  String get targetExtension => 'pdf';

  @override
  List<String> get allowedExtensions => ['pdf'];

  @override
  Future<Directory> get saveDirectory => FileManager.getCropPdfDirectory();

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _wController.dispose();
    _hController.dispose();
    super.dispose();
  }

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) async {
    if (file == null) throw Exception('File is null');

    final x = int.tryParse(_xController.text.trim()) ?? 0;
    final y = int.tryParse(_yController.text.trim()) ?? 0;
    final w = int.tryParse(_wController.text.trim()) ?? 100;
    final h = int.tryParse(_hController.text.trim()) ?? 100;

    final res = await _service.cropPdf(
      file,
      x,
      y,
      w,
      h,
      outputFilename: outputName,
    );
    
    if (res == null) return null;
    
    return ImageToPdfResult(
      file: res,
      fileName: outputName ?? 'cropped_${basename(file.path)}',
      downloadUrl: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Crop PDF',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
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
                const ConversionHeaderCardWidget(
                  title: 'Crop PDF',
                  description: 'Crop your PDF documents to specific dimensions or remove unwanted margins.',
                  iconTarget: Icons.crop,
                  iconSource: Icons.crop,
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select PDF File',
                ),
                const SizedBox(height: 16),
                if (model.selectedFile != null)
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: formatBytes(model.selectedFile!.lengthSync()),
                    fileIcon: Icons.picture_as_pdf,
                    onRemove: resetForNewConversion,
                  ),
                const SizedBox(height: 16),
                
                // Crop Settings
                if (model.selectedFile != null) ...[
                  // Crop Settings
                  _buildOptionsCard(),

                  const SizedBox(height: 16),
                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    extensionLabel: '.pdf extension is added automatically',
                  ),
                  const SizedBox(height: 20),
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Crop PDF',
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
                      title: 'PDF Ready',
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

  Widget _buildOptionsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Crop Settings', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _xController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                     labelText: 'X (mm)',
                     hintText: '0',
                     labelStyle: const TextStyle(color: AppColors.textSecondary),
                     hintStyle: const TextStyle(color: AppColors.textTertiary),
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                     filled: true,
                     fillColor: AppColors.backgroundDark,
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _yController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                     labelText: 'Y (mm)',
                     hintText: '0',
                     labelStyle: const TextStyle(color: AppColors.textSecondary),
                     hintStyle: const TextStyle(color: AppColors.textTertiary),
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                     filled: true,
                     fillColor: AppColors.backgroundDark,
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _wController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                     labelText: 'Width (mm)',
                     hintText: '210',
                     labelStyle: const TextStyle(color: AppColors.textSecondary),
                     hintStyle: const TextStyle(color: AppColors.textTertiary),
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                     filled: true,
                     fillColor: AppColors.backgroundDark,
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _hController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                     labelText: 'Height (mm)',
                     hintText: '297',
                     labelStyle: const TextStyle(color: AppColors.textSecondary),
                     hintStyle: const TextStyle(color: AppColors.textTertiary),
                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                     filled: true,
                     fillColor: AppColors.backgroundDark,
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
