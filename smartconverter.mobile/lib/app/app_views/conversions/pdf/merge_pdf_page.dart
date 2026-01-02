import '../../../app_modules/imports_module.dart';

class MergePdfPage extends StatefulWidget {
  const MergePdfPage({super.key});

  @override
  State<MergePdfPage> createState() => _MergePdfPageState();
}

class _MergePdfPageState extends State<MergePdfPage> with AdHelper {
  final ConversionService _service = ConversionService();
  final TextEditingController _fileNameController = TextEditingController();

  List<File> _selectedFiles = [];
  MergePdfResult? _mergeResult;
  bool _isMerging = false;
  bool _isSaving = false;
  bool _fileNameEdited = false;
  String _statusMessage = 'Select at least 2 PDF files to begin.';
  String? _suggestedBaseName;
  String? _targetDirectoryPath;
  String? _savedFilePath;

  @override
  void initState() {
    super.initState();
    _fileNameController.addListener(_handleFileNameChange);
    _loadTargetDirectoryPath();
  }

  @override
  void dispose() {
    _fileNameController
      ..removeListener(_handleFileNameChange)
      ..dispose();
    super.dispose();
  }

  void _handleFileNameChange() {
    final trimmed = _fileNameController.text.trim();
    final edited = trimmed.isNotEmpty;
    if (_fileNameEdited != edited) {
      setState(() => _fileNameEdited = edited);
    }
  }

  Future<void> _loadTargetDirectoryPath() async {
    try {
      final dir = await FileManager.getMergedPdfsDirectory();
      if (mounted) {
        setState(() => _targetDirectoryPath = dir.path);
      }
    } catch (_) {
      // Silently ignore
    }
  }

  Future<void> _pickPdfFiles({required bool append}) async {
    try {
      final files = await _service.pickMultipleFiles(
        allowedExtensions: const ['pdf'],
        type: 'pdf',
      );

      if (files.isEmpty) {
        if (!append && _selectedFiles.isEmpty) {
          setState(() => _statusMessage = 'No files selected.');
        }
        return;
      }

      setState(() {
        final existingPaths = _selectedFiles.map((f) => f.path).toSet();
        final newFiles = append ? _selectedFiles.toList() : <File>[];
        for (final file in files) {
          if (!existingPaths.contains(file.path)) {
            newFiles.add(file);
          }
        }
        _selectedFiles = newFiles;
        _mergeResult = null;
        _savedFilePath = null;
        _statusMessage = '${_selectedFiles.length} PDF files selected.';
        resetAdStatus(null);
      });

      _updateSuggestedFileName();
    } catch (e) {
      final message = 'Failed to select PDF files: $e';
      if (mounted) {
        setState(() => _statusMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.warning),
        );
      }
    }
  }

  void _updateSuggestedFileName() {
    if (_selectedFiles.length < 2) {
      setState(() {
        _suggestedBaseName = null;
        _savedFilePath = null;
        if (!_fileNameEdited) {
          _fileNameController.clear();
        }
      });
      return;
    }

    final baseNames = _selectedFiles
        .map((file) => basenameWithoutExtension(file.path))
        .where((name) => name.isNotEmpty)
        .toList();

    if (baseNames.isEmpty) {
      baseNames.addAll(
        List<String>.generate(
          _selectedFiles.length,
          (index) => 'file_${index + 1}',
        ),
      );
    }

    var suggestion = baseNames.take(4).join('_');
    if (baseNames.length > 4) {
      suggestion += '_plus${baseNames.length - 4}';
    }

    final sanitized = _sanitizeBaseName(suggestion);

    setState(() {
      _suggestedBaseName = sanitized;
      if (!_fileNameEdited) {
        _fileNameController.text = sanitized;
      }
    });
  }

  void _reorderFiles(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final file = _selectedFiles.removeAt(oldIndex);
      _selectedFiles.insert(newIndex, file);
      _mergeResult = null;
      _savedFilePath = null;
      _statusMessage = '${_selectedFiles.length} PDF files selected.';
      resetAdStatus(null);
    });
    _updateSuggestedFileName();
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _mergeResult = null;
      _savedFilePath = null;
      if (_selectedFiles.isEmpty) {
        _statusMessage = 'Select at least 2 PDF files to begin.';
      } else {
        _statusMessage = '${_selectedFiles.length} PDF files selected.';
      }
    });
    _updateSuggestedFileName();
  }

  Future<void> _mergeSelectedFiles() async {
    if (_selectedFiles.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 2 PDF files before merging.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Check for rewarded ad first
    final adWatched = await showRewardedAdGate(toolName: 'Merge PDF');
    if (!adWatched) {
      return;
    }

    setState(() {
      _isMerging = true;
      _statusMessage = 'Merging PDFs...';
      _mergeResult = null;
      _savedFilePath = null;
    });

    try {
      final preferredBase = _fileNameController.text.trim().isNotEmpty
          ? _fileNameController.text.trim()
          : _suggestedBaseName ?? 'merged_document';

      final sanitizedBase = _sanitizeBaseName(preferredBase);
      final requestFileName = _ensurePdfExtension(sanitizedBase);

      final result = await _service.mergePdfFiles(
        _selectedFiles,
        outputFileName: requestFileName,
      );

      if (!mounted) return;

      if (result == null) {
        setState(() {
          _statusMessage =
              'Merge completed but no file returned. Please try again.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Merge completed, but unable to download the file.'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      setState(() {
        _mergeResult = result;
        _statusMessage = 'PDFs merged successfully!';
        _savedFilePath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Merged file ready: ${result.fileName}'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Merge failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isMerging = false);
      }
    }
  }

  Future<void> _saveMergedFile() async {
    final result = _mergeResult;
    if (result == null) return;

    // Show Interstitial Ad before saving if ready
    await showInterstitialAd();

    setState(() => _isSaving = true);

    try {
      final directory = await FileManager.getMergedPdfsDirectory();
      String targetFileName = result.fileName;
      File destinationFile = File(join(directory.path, targetFileName));

      if (await destinationFile.exists()) {
        final fallbackName = FileManager.generateTimestampFilename(
          _sanitizeBaseName(basenameWithoutExtension(targetFileName)),
          'pdf',
        );
        targetFileName = fallbackName;
        destinationFile = File(join(directory.path, targetFileName));
      }

      final savedFile = await result.file.copy(destinationFile.path);

      if (!mounted) return;

      setState(() => _savedFilePath = savedFile.path);

      // Trigger System Notification
      await NotificationService.showFileSavedNotification(
        fileName: targetFileName,
        filePath: savedFile.path,
      );

      if (mounted) {
        setState(() {
          _statusMessage = 'File saved successfully!';
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _shareMergedFile() async {
    final result = _mergeResult;
    if (result == null) return;
    final pathToShare = _savedFilePath ?? result.file.path;
    final fileToShare = File(pathToShare);

    if (!await fileToShare.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Merged file is not available on disk.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    await Share.shareXFiles([
      XFile(fileToShare.path),
    ], text: 'Merged PDF: ${result.fileName}');
  }

  void _resetForNewMerge() {
    setState(() {
      _selectedFiles = [];
      _mergeResult = null;
      _savedFilePath = null;
      _isMerging = false;
      _isSaving = false;
      _fileNameEdited = false;
      _suggestedBaseName = null;
      _statusMessage = 'Select at least 2 PDF files to begin.';
      _fileNameController.clear();
      resetAdStatus(null);
    });
  }

  int _totalBytesSelected() {
    int total = 0;
    for (final file in _selectedFiles) {
      try {
        total += file.lengthSync();
      } catch (_) {
        continue;
      }
    }
    return total;
  }
  
  String _sanitizeBaseName(String input) {
    var base = input.trim();
    if (base.toLowerCase().endsWith('.pdf')) {
      base = base.substring(0, base.length - 4);
    }
    base = base.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    base = base.replaceAll(RegExp(r'_+'), '_');
    base = base.trim().replaceAll(RegExp(r'^_|_$'), '');
    if (base.isEmpty) {
      base = 'merged_document';
    }
    return base.substring(0, min(base.length, 80));
  }

  String _ensurePdfExtension(String base) {
    final trimmed = base.trim();
    return trimmed.toLowerCase().endsWith('.pdf') ? trimmed : '$trimmed.pdf';
  }

  String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    final digitGroups = (log(bytes) / log(1024)).floor();
    final clampedGroups = digitGroups.clamp(0, units.length - 1);
    final value = bytes / pow(1024, clampedGroups);
    return '${value.toStringAsFixed(value >= 10 || clampedGroups == 0 ? 0 : 1)} ${units[clampedGroups]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Merge PDF',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
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
                  title: 'Merge PDF Files',
                  description: 'Combine multiple PDFs into a single document. Reorder files, choose a custom output name, save, or share instantly.',
                  iconTarget: Icons.picture_as_pdf_outlined,
                  iconSource: Icons.picture_as_pdf,
                ),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 16),
                if (_selectedFiles.length >= 2) ...[
                  ConversionFileNameFieldWidget(
                    controller: _fileNameController,
                    suggestedName: _suggestedBaseName,
                    extensionLabel: '.pdf extension is added automatically',
                  ),
                  const SizedBox(height: 16),
                ],
                _buildSelectionSummary(),
                const SizedBox(height: 16),
                _buildSelectedFilesList(),
                const SizedBox(height: 20),
                if (_selectedFiles.length >= 2)
                  _buildMergeButton(),
                const SizedBox(height: 16),
                ConversionStatusWidget(
                  isConverting: _isMerging,
                  statusMessage: _statusMessage,
                ),
                if (_mergeResult != null) ...[
                  const SizedBox(height: 20),
                  if (_savedFilePath == null)
                    ConversionFileSaveCardWidget(
                      fileName: _mergeResult!.fileName,
                      isSaving: _isSaving,
                      onSave: _saveMergedFile,
                      title: 'Merged PDF Ready',
                    )
                  else
                    ConversionResultCardWidget(
                      savedFilePath: _savedFilePath!,
                      onShare: _shareMergedFile,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBannerAd(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isMerging
                ? null
                : () => _pickPdfFiles(append: _selectedFiles.isNotEmpty),
            icon: const Icon(Icons.file_open_outlined),
            label: Text(
              _selectedFiles.isEmpty ? 'Select PDF Files' : 'Add More PDFs',
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 56,
            child: ElevatedButton(
              onPressed: _isMerging ? null : _resetForNewMerge,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectionSummary() {
    if (_selectedFiles.isEmpty) {
      return const SizedBox();
    }

    final totalBytes = _totalBytesSelected();
    final totalSize = formatBytes(totalBytes);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip(
          icon: Icons.picture_as_pdf,
          label: 'Files: ${_selectedFiles.length}',
        ),
        _buildChip(
          icon: Icons.storage_rounded,
          label: 'Total size: $totalSize',
        ),
      ],
    );
  }

  Widget _buildChip({required IconData icon, required String label}) {
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.primaryBlue),
      backgroundColor: AppColors.backgroundSurface,
      label: Text(label, style: const TextStyle(color: AppColors.textPrimary)),
      side: BorderSide.none,
    );
  }

  Widget _buildSelectedFilesList() {
    if (_selectedFiles.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'No PDF files selected yet.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap "Select PDF Files" to choose two or more PDFs. You can reorder them after selection.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _selectedFiles.length,
        onReorder: _reorderFiles,
        padding: const EdgeInsets.symmetric(vertical: 4),
        buildDefaultDragHandles: false,
        itemBuilder: (context, index) {
          final file = _selectedFiles[index];
          final fileName = basename(file.path);
          final fileSize = formatBytes(file.lengthSync());

          return ListTile(
            key: ValueKey(file.path),
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              fileName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              fileSize,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(
                    Icons.drag_indicator,
                    color: AppColors.textSecondary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  tooltip: 'Remove file',
                  onPressed: _isMerging ? null : () => _removeFile(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMergeButton() {
    final canMerge = _selectedFiles.length >= 2 && !_isMerging;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canMerge ? _mergeSelectedFiles : null,
        icon: _isMerging
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary),
              )
            : const Icon(Icons.merge_type_outlined),
        label: Text(_isMerging ? 'Merging...' : 'Merge PDFs'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
