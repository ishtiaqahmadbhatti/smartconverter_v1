import '../../../app_modules/imports_module.dart';

class MarkdownToEpubPage extends StatefulWidget {
  const MarkdownToEpubPage({super.key});

  @override
  State<MarkdownToEpubPage> createState() => _MarkdownToEpubPageState();
}

class _MarkdownToEpubPageState extends State<MarkdownToEpubPage> with AdHelper, ConversionMixin {
  final ConversionModel _model = ConversionModel(statusMessage: 'Select a Markdown file to begin.');
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(text: 'Converted Book');
  final TextEditingController _authorController = TextEditingController(text: 'Unknown');
  final ConversionService _service = ConversionService();

  @override
  ConversionModel get model => _model;

  @override
  TextEditingController get fileNameController => _fileNameController;

  @override
  ConversionService get service => _service;

  @override
  String get conversionToolName => 'Convert Markdown to ePUB';

  @override
  String get fileTypeLabel => 'Markdown';

  @override
  String get targetExtension => 'epub';

  @override
  List<String> get allowedExtensions => ['md'];

  @override
  Future<Directory> get saveDirectory => FileManager.getMarkdownToEpubDirectory();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) {
    if (file == null) throw Exception('File is null');
    return service.convertEbook(
      file,
      outputFilename: outputName,
      endpoint: ApiConfig.ebookMarkdownToEpubEndpoint,
      outputExt: targetExtension,
      extraParams: {
        'title': _titleController.text.trim().isEmpty ? 'Converted Book' : _titleController.text.trim(),
        'author': _authorController.text.trim().isEmpty ? 'Unknown' : _authorController.text.trim(),
      },
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
                  description: 'Transform Markdown files into ePUB eBooks.',
                  iconTarget: Icons.book,
                  iconSource: Icons.text_snippet, 
                ),
                const SizedBox(height: 20),
                ConversionActionButtonWidget(
                  onPickFile: () => pickFile(),
                  isFileSelected: model.selectedFile != null,
                  isConverting: model.isConverting,
                  onReset: resetForNewConversion,
                  buttonText: 'Select Markdown File',
                ),
                const SizedBox(height: 16),
                if (model.selectedFile != null) ...[
                  ConversionSelectedFileCardWidget(
                    fileName: basename(model.selectedFile!.path),
                    fileSize: getSafeFileSize(model.selectedFile!),
                    fileIcon: Icons.text_snippet,
                    onRemove: resetForNewConversion,
                  ),
                  const SizedBox(height: 16),
                  // Extra Fields for Markdown
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Book Title',
                      filled: true,
                      fillColor: AppColors.backgroundSurface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.title),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _authorController,
                    decoration: InputDecoration(
                      labelText: 'Author Name',
                      filled: true,
                      fillColor: AppColors.backgroundSurface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 16),
                ],
                ConversionFileNameFieldWidget(
                  controller: fileNameController,
                  suggestedName: model.suggestedBaseName,
                  extensionLabel: '.$targetExtension extension is added automatically',
                ),
                const SizedBox(height: 20),
                if (model.selectedFile != null)
                  ConversionConvertButtonWidget(
                    onConvert: convert,
                    isConverting: model.isConverting,
                    isEnabled: true,
                    buttonText: 'Convert to ePUB',
                  ),
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
                      title: 'ePUB File Ready',
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
