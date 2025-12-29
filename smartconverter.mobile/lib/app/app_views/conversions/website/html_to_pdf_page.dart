import '../../../app_modules/imports_module.dart';

class HtmlToPdfPage extends StatefulWidget {
  final String? categoryId;
  const HtmlToPdfPage({super.key, this.categoryId});

  @override
  State<HtmlToPdfPage> createState() => _HtmlToPdfPageState();
}

class _HtmlToPdfPageState extends State<HtmlToPdfPage>
    with SingleTickerProviderStateMixin, AdHelper, ConversionMixin {
  final TextEditingController _htmlContentController = TextEditingController();
  final TextEditingController _cssContentController = TextEditingController();
  late TabController _tabController;

  @override
  final ConversionService service = ConversionService();

  @override
  final ConversionModel model = ConversionModel(statusMessage: 'Select a file or paste HTML content.');

  @override
  final TextEditingController fileNameController = TextEditingController();

  @override
  String get fileTypeLabel => 'HTML';

  @override
  List<String> get allowedExtensions => ['html', 'htm'];

  @override
  String get conversionToolName => 'HtmlToPdf';

  @override
  String get convertingMessage => 'Converting HTML to PDF...';

  @override
  String get successMessage => 'PDF generated successfully!';
  
  // Dynamic requirement based on tab
  @override
  bool get requiresInputFile => _tabController.index == 0;

  @override
  String get targetExtension => '.pdf';

  @override
  Future<Directory> get saveDirectory async {
    return widget.categoryId == 'website_conversion'
        ? await FileManager.getWebsiteHtmlToPdfDirectory()
        : await FileManager.getHtmlToPdfDirectory();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabSelection);
    fileNameController.addListener(handleFileNameChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _htmlContentController.dispose();
    _cssContentController.dispose();
    fileNameController.removeListener(handleFileNameChange);
    fileNameController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        // Reset status when switching tabs
        model.statusMessage = 'Select a file or paste HTML content.';
        model.conversionResult = null;
        model.savedFilePath = null;
        // Verify mixin state logic if needed, usually setState is enough
      });
    }
  }

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) async {
    if (_tabController.index == 0) {
      // File mode
      if (file == null) throw Exception('Please select an HTML file');
      return await service.convertHtmlToPdf(
        htmlFile: file,
        outputFilename: outputName,
      );
    } else {
      // HTML Content mode
      final content = _htmlContentController.text;
      if (content.isEmpty) throw Exception('Please enter HTML content');
      
      return await service.convertHtmlToPdf(
        htmlContent: content,
        cssContent: _cssContentController.text.trim().isNotEmpty
            ? _cssContentController.text
            : null,
        outputFilename: outputName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'HTML to PDF',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'File'),
            Tab(text: 'HTML Content'),
          ],
        ),
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
                  title: 'Convert HTML to PDF',
                  description: 'Convert HTML files or raw content to PDF documents',
                  sourceIcon: Icons.code,
                  destinationIcon: Icons.picture_as_pdf,
                ),
                const SizedBox(height: 20),
                
                // Tab Content
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return _tabController.index == 0
                        ? _buildFileInput()
                        : _buildHtmlInput();
                  },
                ),
                
                const SizedBox(height: 16),
                
                ConversionFileNameFieldWidget(
                  controller: fileNameController,
                  suggestedName: model.suggestedBaseName,
                  extensionLabel: '.pdf will be added automatically',
                ),
                
                const SizedBox(height: 20),
                
                ConversionConvertButtonWidget(label: 'Convert to PDF',
                  icon: Icons.transform,
                  onPressed: convert,
                  isLoading: model.isConverting,
                ),
                
                const SizedBox(height: 16),
                
                ConversionStatusWidget(
                  statusMessage: model.statusMessage,
                  isConverting: model.isConverting,
                  conversionResult: model.conversionResult,
                ),
                
                if (model.conversionResult != null) ...[
                  const SizedBox(height: 20),
                  ConversionFileSaveCardWidget(
                    fileName: model.conversionResult!.fileName,
                    isSaving: model.isSaving,
                    onSave: saveResult,
                    title: 'PDF File Ready',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: getBannerAdWidget(),
    );
  }

  Widget _buildFileInput() {
    return Column(
      children: [
        if (model.selectedFile == null)
          _buildPickFileButton()
        else
          ConversionFileCardWidget(
            fileTypeLabel: fileTypeLabel,
            fileName: basename(model.selectedFile!.path),
            fileSize: formatBytes(model.selectedFile!.lengthSync()),
            onRemove: () => resetForNewConversion(customStatus: 'Select an HTML file to begin.'),
          ),
      ],
    );
  }

  Widget _buildPickFileButton() {
    return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: model.isConverting ? null : pickFile,
          icon: const Icon(Icons.file_open_outlined),
          label: const Text('Select HTML File'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
    );
  }

  Widget _buildHtmlInput() {
    return Column(
      children: [
        TextField(
          controller: _htmlContentController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'HTML Content',
            hintText: 'Paste your HTML code here...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.backgroundSurface,
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cssContentController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'CSS Content (Optional)',
            hintText: 'body { color: red; }',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: AppColors.backgroundSurface,
          ),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

