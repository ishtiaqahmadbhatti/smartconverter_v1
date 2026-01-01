import '../../../app_modules/imports_module.dart';

class ExtractPagesPage extends StatefulWidget {
  const ExtractPagesPage({super.key});

  @override
  State<ExtractPagesPage> createState() => _ExtractPagesPageState();
}

class _ExtractPagesPageState extends State<ExtractPagesPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select a PDF file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final ConversionService _service = ConversionService();
  final TextEditingController _rangesController = TextEditingController();

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Extract Pages';

  @override
  String get fileTypeLabel => 'PDF';

  @override
  String get targetExtension => 'pdf';

  @override
  List<String> get allowedExtensions => ['pdf'];

  @override
  Future<Directory> get saveDirectory => FileManager.getExtractPagesDirectory();

  @override
  void dispose() {
    _rangesController.dispose();
    super.dispose();
  }

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) async {
    if (file == null) throw Exception('File is null');

    final rangesText = _rangesController.text.trim();
    if (rangesText.isEmpty) {
      throw Exception('Enter pages to extract.');
    }

    final pages = _parseRanges(rangesText);
    
    final res = await _service.extractPages(
      file,
      pages,
      outputFilename: outputName,
    );
    
    if (res == null) return null;
    
    return ImageToPdfResult(
      file: res,
      fileName: outputName ?? 'extracted_${basename(file.path)}',
      downloadUrl: '',
    );
  }

  List<int> _parseRanges(String input) {
    final tokens = input.split(RegExp(r'[\,\s]+')).where((t) => t.trim().isNotEmpty).toList();
    final pages = <int>[];
    for (final token in tokens) {
      final t = token.trim();
      if (t.contains('-')) {
        final parts = t.split('-');
        final start = int.tryParse(parts.first.trim());
        final end = int.tryParse(parts.last.trim());
        if (start != null && end != null) {
          final a = start <= end ? start : end;
          final b = start <= end ? end : start;
          for (int i = a; i <= b; i++) {
            pages.add(i);
          }
        }
      } else {
        final num = int.tryParse(t);
        if (num != null) pages.add(num);
      }
    }
    final seen = <int>{};
    return pages.where((p) => seen.add(p)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Extract Pages',
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
                  title: 'Extract Pages',
                  description: 'Extract specific pages from your PDF documents into a new file.',
                  iconTarget: Icons.content_copy,
                  iconSource: Icons.content_copy,
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
                
                // Ranges Input
                if (model.selectedFile != null) ...[
                  // Ranges Input
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
                    buttonText: 'Extract Pages',
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
          const Text('Extraction Settings', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _rangesController,
            decoration: InputDecoration(
              labelText: 'Pages to Extract',
              hintText: 'e.g., 1-5, 7, 9-12',
              helperText: 'Enter page ranges or single page numbers',
              helperStyle: const TextStyle(color: AppColors.textTertiary),
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
