import '../../../app_modules/imports_module.dart';

class HtmlTableToCsvPage extends StatefulWidget {
  final String? categoryId;
  const HtmlTableToCsvPage({super.key, this.categoryId});

  @override
  State<HtmlTableToCsvPage> createState() => _HtmlTableToCsvPageState();
}

class _HtmlTableToCsvPageState extends State<HtmlTableToCsvPage>
    with SingleTickerProviderStateMixin, AdHelper, ConversionMixin {
  final TextEditingController _htmlContentController = TextEditingController();
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
  String get conversionToolName => 'HtmlTableToCsv';

  @override
  String get convertingMessage => 'Converting HTML Table to CSV...';

  @override
  String get successMessage => 'CSV generated successfully!';

  // Dynamic requirement based on tab
  @override
  bool get requiresInputFile => _tabController.index == 0;

  @override
  String get targetExtension => '.csv';

  @override
  Future<Directory> get saveDirectory => FileManager.getWebsiteHtmlToCsvDirectory();

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
      });
    }
  }

  @override
  Future<ImageToPdfResult?> performConversion(File? file, String? outputName) async {
    if (_tabController.index == 0) {
      // File mode
      if (file == null) throw Exception('Please select an HTML file');
      return await service.convertHtmlTableToCsv(
        htmlFile: file,
        outputFilename: outputName,
      );
    } else {
      // HTML Content mode
      final content = _htmlContentController.text;
      if (content.isEmpty) throw Exception('Please enter HTML content');
      
      return await service.convertHtmlTableToCsv(
        htmlContent: content,
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
          'HTML Table to CSV',
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
                  title: 'Convert HTML Table to CSV',
                  description: 'Extract tables from HTML files or content to CSV format',
                  sourceIcon: Icons.grid_on,
                  destinationIcon: Icons.table_view,
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
                
                if (_tabController.index == 1 || (_tabController.index == 0 && model.selectedFile != null)) ...[
                  ConversionFileNameFieldWidget(
                    controller: fileNameController,
                    suggestedName: model.suggestedBaseName,
                    extensionLabel: '.csv will be added automatically',
                  ),
                  
                  const SizedBox(height: 20),
                  
                  ConversionConvertButtonWidget(label: 'Convert to CSV',
                    icon: Icons.transform,
                    onPressed: convert,
                    isLoading: model.isConverting,
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
                      title: 'CSV File Ready',
                    )
                  else
                    ConversionResultCardWidget(
                      savedFilePath: model.savedFilePath!,
                      onShare: shareFile,
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
        ConversionActionButtonWidget(
          isFileSelected: model.selectedFile != null,
          onPickFile: pickFile,
          onReset: () => resetForNewConversion(customStatus: 'Select an HTML file to begin.'),
          isConverting: model.isConverting,
          buttonText: 'Select HTML File',
        ),
        
        if (model.selectedFile != null) ...[
          const SizedBox(height: 16),
          ConversionSelectedFileCardWidget(
            fileTypeLabel: fileTypeLabel,
            fileName: basename(model.selectedFile!.path),
            fileSize: formatBytes(model.selectedFile!.lengthSync()),
            fileIcon: Icons.description,
            onRemove: () => resetForNewConversion(customStatus: 'Select an HTML file to begin.'),
          ),
        ],
      ],
    );
  }

  Widget _buildHtmlInput() {
    return Column(
      children: [
        TextField(
          controller: _htmlContentController,
          maxLines: 8,
          decoration: InputDecoration(
            labelText: 'HTML Content',
            hintText: 'Paste your HTML code here...',
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

