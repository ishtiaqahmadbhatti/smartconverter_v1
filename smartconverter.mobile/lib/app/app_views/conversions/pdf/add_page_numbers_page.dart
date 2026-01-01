import '../../../app_modules/imports_module.dart';

class AddPageNumbersPage extends StatefulWidget {
  const AddPageNumbersPage({super.key});

  @override
  State<AddPageNumbersPage> createState() => _AddPageNumbersPageState();
}

class _AddPageNumbersPageState extends State<AddPageNumbersPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select a PDF file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();

  // Custom controllers
  final TextEditingController _formatController = TextEditingController(text: '{page}');
  final TextEditingController _startPageController = TextEditingController(text: '1');
  final TextEditingController _fontSizeController = TextEditingController(text: '12');
  
  String _position = 'bottom-center';
  final List<String> _positions = const [
    'top-left', 'top-center', 'top-right',
    'bottom-left', 'bottom-center', 'bottom-right',
  ];

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Add Page Numbers';

  @override
  String get fileTypeLabel => 'PDF';

  @override
  String get targetExtension => 'pdf';

  @override
  List<String> get allowedExtensions => ['pdf'];

  @override
  Future<Directory> get saveDirectory => FileManager.getPageNumberPdfDirectory();

  @override
  void dispose() {
    _formatController.dispose();
    _startPageController.dispose();
    _fontSizeController.dispose();
    super.dispose();
  }

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) async {
    if (file == null) throw Exception('File is null');

    final fmt = _formatController.text.trim().isEmpty ? '{page}' : _formatController.text.trim();
    final startPage = int.tryParse(_startPageController.text.trim()) ?? 1;
    final fontSize = double.tryParse(_fontSizeController.text.trim()) ?? 12.0;

    final res = await _service.addPageNumbersToPdf(
      file,
      position: _position,
      startPage: startPage,
      format: fmt,
      fontSize: fontSize,
      outputFilename: outputName,
    );
    
    if (res == null) return null;
    
    // The service returns a File, we need to wrap it in ImageToPdfResult (assuming service returns File)
    // Wait, check service method signature. addPageNumbersToPdf returns Future<File?>.
    // ConversionMixin expects ImageToPdfResult?. 
    // I need to wrap it.
    
    // Actually, ConversionMixin logic in `convert` calls `performConversion`.
    // If `performConversion` returns `ImageToPdfResult`, good.
    // If the service returns `File`, I need to wrap it.
    
    return ImageToPdfResult(
      file: res,
      fileName: outputName ?? 'numbered_${basename(file.path)}',
      downloadUrl: '',
    ); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Add Page Numbers',
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
                  title: 'Add Page Numbers',
                  description: 'Insert page numbers into your PDF documents with custom formatting and positioning.',
                  iconTarget: Icons.format_list_numbered,
                  iconSource: Icons.picture_as_pdf,
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
                
                // Custom Options
                if (model.selectedFile != null) ...[
                  // Custom Options
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
                    buttonText: 'Apply Page Numbers',
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
          const Text('Options', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Position:', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _position,
                  dropdownColor: AppColors.backgroundDark,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                  items: _positions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: model.isConverting ? null : (v) => setState(() => _position = v ?? 'bottom-center'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _startPageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                     labelText: 'Start Number',
                     hintText: '1',
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
                  controller: _fontSizeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                     labelText: 'Font Size',
                     hintText: '12',
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
          TextField(
            controller: _formatController,
            decoration: InputDecoration(
               labelText: 'Format (use {page} placeholder)',
               hintText: '{page}',
               labelStyle: const TextStyle(color: AppColors.textSecondary),
               hintStyle: const TextStyle(color: AppColors.textTertiary),
               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
               filled: true,
               fillColor: AppColors.backgroundDark,
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
