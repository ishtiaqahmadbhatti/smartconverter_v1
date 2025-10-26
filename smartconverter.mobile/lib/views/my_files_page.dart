import 'package:flutter/material.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../widgets/futuristic_card.dart';
import '../utils/file_manager.dart';
import 'package:path/path.dart' as path;

class MyFilesPage extends StatefulWidget {
  const MyFilesPage({super.key});

  @override
  State<MyFilesPage> createState() => _MyFilesPageState();
}

class _MyFilesPageState extends State<MyFilesPage> {
  Directory? _currentDirectory;
  List<FileSystemEntity> _currentItems = [];
  bool _isLoading = false;
  String _currentPath = '';

  @override
  void initState() {
    super.initState();
    _loadSmartConverterDirectory();
    _checkExistingFiles(); // Check for existing files on startup
  }

  Future<void> _loadSmartConverterDirectory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final smartConverterDir = await FileManager.getSmartConverterDirectory();
      print('DEBUG: SmartConverter directory path: ${smartConverterDir.path}');
      print(
        'DEBUG: SmartConverter directory exists: ${await smartConverterDir.exists()}',
      );

      if (await smartConverterDir.exists()) {
        setState(() {
          _currentDirectory = smartConverterDir;
          _currentPath = 'SmartConverter';
        });
        await _loadDirectoryContents(smartConverterDir);
      } else {
        setState(() {
          _currentItems = [];
          _currentPath = 'SmartConverter (Empty)';
        });
      }
    } catch (e) {
      _showErrorDialog('Error Loading Directory', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDirectoryContents(Directory directory) async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('DEBUG: Loading directory: ${directory.path}');

      // Check if directory exists
      if (!await directory.exists()) {
        print('DEBUG: Directory does not exist');
        final computedPath = await _getRelativePath(directory.path);
        setState(() {
          _currentItems = [];
          _currentDirectory = directory;
          _currentPath = computedPath;
        });
        return;
      }

      // Use async listing for better error handling
      List<FileSystemEntity> items = await directory.list().toList();
      print('DEBUG: Found ${items.length} items in directory');

      // If no items found, try alternative methods
      if (items.isEmpty) {
        print('DEBUG: No items found with async list(), trying sync method...');
        try {
          items = directory.listSync();
          print('DEBUG: Sync method found ${items.length} items');
        } catch (e) {
          print('DEBUG: Sync method also failed: $e');
        }
      }

      // If still no items, try with different options
      if (items.isEmpty) {
        print('DEBUG: Still no items, trying with explicit options...');
        try {
          items = directory.listSync(recursive: false, followLinks: false);
          print('DEBUG: Explicit options found ${items.length} items');
        } catch (e) {
          print('DEBUG: Explicit options also failed: $e');
        }
      }

      // Log each item for debugging
      print('DEBUG: Final item count: ${items.length}');
      for (final item in items) {
        print('DEBUG: Item: ${item.path} (${item.runtimeType})');
        if (item is File) {
          try {
            final stat = await item.stat();
            print(
              'DEBUG: File size: ${stat.size} bytes, exists: ${await item.exists()}',
            );
          } catch (e) {
            print('DEBUG: Could not get file stats: $e');
          }
        } else if (item is Directory) {
          try {
            final exists = await item.exists();
            print('DEBUG: Directory exists: $exists');
          } catch (e) {
            print('DEBUG: Could not check directory existence: $e');
          }
        }
      }

      // Sort: directories first, then files, alphabetically
      items.sort((a, b) {
        if (a is Directory && b is File) return -1;
        if (a is File && b is Directory) return 1;
        return a.path.toLowerCase().compareTo(b.path.toLowerCase());
      });

      final computedPath = await _getRelativePath(directory.path);

      print('DEBUG: Setting state with ${items.length} items');
      setState(() {
        _currentItems = items;
        _currentDirectory = directory;
        _currentPath = computedPath;
      });

      print('DEBUG: State updated successfully');
    } catch (e) {
      print('DEBUG: Error loading directory contents: $e');
      _showErrorDialog(
        'Error Loading Contents',
        'Could not load directory contents: $e',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getRelativePath(String fullPath) async {
    final smartConverterDir = await FileManager.getSmartConverterDirectory();
    final relativePath = path.relative(fullPath, from: smartConverterDir.path);
    if (relativePath == '.') {
      return 'SmartConverter';
    }
    return 'SmartConverter/$relativePath';
  }

  void _navigateToParent() async {
    if (_currentDirectory != null) {
      final parent = _currentDirectory!.parent;
      final smartConverterDir = await FileManager.getSmartConverterDirectory();

      // Don't go beyond SmartConverter directory
      if (parent.path != smartConverterDir.parent.path) {
        await _loadDirectoryContents(parent);
      }
    }
  }

  void _navigateToDirectory(Directory directory) async {
    print('DEBUG: Navigating to directory: ${directory.path}');

    try {
      final exists = await directory.exists();
      print('DEBUG: Directory exists: $exists');

      if (!exists) {
        _showErrorDialog(
          'Directory Not Found',
          'The selected directory does not exist.',
        );
        return;
      }

      await _loadDirectoryContents(directory);
    } catch (e) {
      print('DEBUG: Error navigating to directory: $e');
      _showErrorDialog(
        'Navigation Error',
        'Could not navigate to directory: $e',
      );
    }
  }

  Future<void> _createTestFile() async {
    try {
      // Create test files in different tool directories
      final testDirs = [
        await FileManager.getMergePdfDirectory(),
        await FileManager.getProtectPdfDirectory(),
        await FileManager.getWatermarkPdfDirectory(),
      ];

      for (final testDir in testDirs) {
        final testFile = File(
          '${testDir.path}/test_file_${DateTime.now().millisecondsSinceEpoch}.txt',
        );
        await testFile.writeAsString(
          'Test file content created at ${DateTime.now()} in ${testDir.path.split('/').last}',
        );
        print('DEBUG: Created test file: ${testFile.path}');
      }

      // Refresh the current directory
      if (_currentDirectory != null) {
        await _loadDirectoryContents(_currentDirectory!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test files created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      print('DEBUG: Failed to create test files: $e');
      _showErrorDialog('Error', 'Failed to create test files: $e');
    }
  }

  Future<void> _createTestDirectory() async {
    try {
      if (_currentDirectory == null) {
        _showErrorDialog('Error', 'No current directory selected');
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testDir = Directory(
        '${_currentDirectory!.path}/TestFolder_$timestamp',
      );
      await testDir.create(recursive: true);

      // Create a test file inside the new directory
      final testFile = File('${testDir.path}/test_file.txt');
      await testFile.writeAsString('Test file created at ${DateTime.now()}');

      print('DEBUG: Created test directory: ${testDir.path}');

      // Refresh the current directory
      await _loadDirectoryContents(_currentDirectory!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test directory created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      print('DEBUG: Failed to create test directory: $e');
      _showErrorDialog('Error', 'Failed to create test directory: $e');
    }
  }

  Future<void> _forceRefresh() async {
    try {
      print('DEBUG: Force refresh started');

      if (_currentDirectory != null) {
        print(
          'DEBUG: Refreshing current directory: ${_currentDirectory!.path}',
        );
        await _loadDirectoryContents(_currentDirectory!);
      } else {
        print('DEBUG: No current directory, loading SmartConverter root');
        await _loadSmartConverterDirectory();
      }

      // Also run the existing files check
      await _checkExistingFiles();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Directory refreshed'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('DEBUG: Force refresh failed: $e');
      _showErrorDialog('Refresh Error', 'Failed to refresh directory: $e');
    }
  }

  Future<void> _deepScanFiles() async {
    try {
      print('DEBUG: Deep scan started');

      if (_currentDirectory != null) {
        print(
          'DEBUG: Deep scanning current directory: ${_currentDirectory!.path}',
        );
        await _deepScanDirectory(_currentDirectory!);
      } else {
        print('DEBUG: Deep scanning SmartConverter root');
        final smartConverterDir =
            await FileManager.getSmartConverterDirectory();
        await _deepScanDirectory(smartConverterDir);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deep scan completed'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('DEBUG: Deep scan failed: $e');
      _showErrorDialog('Scan Error', 'Failed to scan files: $e');
    }
  }

  Future<void> _deepScanDirectory(Directory directory) async {
    try {
      print('DEBUG: Deep scanning directory: ${directory.path}');

      // Try multiple methods to find files
      List<FileSystemEntity> allItems = [];

      // Method 1: Async list
      try {
        final asyncItems = await directory.list().toList();
        print('DEBUG: Async method found ${asyncItems.length} items');
        allItems.addAll(asyncItems);
      } catch (e) {
        print('DEBUG: Async method failed: $e');
      }

      // Method 2: Sync list
      try {
        final syncItems = directory.listSync();
        print('DEBUG: Sync method found ${syncItems.length} items');
        allItems.addAll(syncItems);
      } catch (e) {
        print('DEBUG: Sync method failed: $e');
      }

      // Method 3: Sync with options
      try {
        final syncItemsWithOptions = directory.listSync(
          recursive: false,
          followLinks: false,
        );
        print(
          'DEBUG: Sync with options found ${syncItemsWithOptions.length} items',
        );
        allItems.addAll(syncItemsWithOptions);
      } catch (e) {
        print('DEBUG: Sync with options failed: $e');
      }

      // Remove duplicates
      final uniqueItems = <String, FileSystemEntity>{};
      for (final item in allItems) {
        uniqueItems[item.path] = item;
      }

      print('DEBUG: Deep scan found ${uniqueItems.length} unique items');
      for (final item in uniqueItems.values) {
        print('DEBUG: Deep scan item: ${item.path} (${item.runtimeType})');
      }

      // If we found items, update the current directory
      if (uniqueItems.isNotEmpty &&
          _currentDirectory != null &&
          _currentDirectory!.path == directory.path) {
        final itemsList = uniqueItems.values.toList();
        itemsList.sort((a, b) {
          if (a is Directory && b is File) return -1;
          if (a is File && b is Directory) return 1;
          return a.path.toLowerCase().compareTo(b.path.toLowerCase());
        });

        setState(() {
          _currentItems = itemsList;
        });
        print('DEBUG: Updated current items with deep scan results');
      }
    } catch (e) {
      print('DEBUG: Deep scan directory failed: $e');
    }
  }

  Future<void> _checkExistingFiles() async {
    try {
      print('DEBUG: Checking for existing files in all directories...');
      final smartConverterDir = await FileManager.getSmartConverterDirectory();

      // Check each tool directory
      final toolDirs = [
        'AddPageNumbers',
        'MergePDF',
        'ProtectPDF',
        'UnlockPDF',
        'WatermarkPDF',
        'RemovePages',
        'RotatePDF',
        'ExtractPages',
      ];

      for (final toolDir in toolDirs) {
        final dir = Directory('${smartConverterDir.path}/$toolDir');
        if (await dir.exists()) {
          try {
            final files = dir.listSync();
            print('DEBUG: $toolDir has ${files.length} items');
            for (final file in files) {
              print('DEBUG: $toolDir - ${file.path} (${file.runtimeType})');
            }
          } catch (e) {
            print('DEBUG: Error listing $toolDir: $e');
            // Try async method
            try {
              final files = await dir.list().toList();
              print('DEBUG: $toolDir async method found ${files.length} items');
            } catch (e2) {
              print('DEBUG: Async method also failed for $toolDir: $e2');
            }
          }
        } else {
          print('DEBUG: $toolDir directory does not exist');
        }
      }

      // Also check current directory if we have one
      if (_currentDirectory != null) {
        print('DEBUG: Checking current directory: ${_currentDirectory!.path}');
        try {
          final currentFiles = await _currentDirectory!.list().toList();
          print('DEBUG: Current directory has ${currentFiles.length} items');
          for (final file in currentFiles) {
            print('DEBUG: Current - ${file.path} (${file.runtimeType})');
          }
        } catch (e) {
          print('DEBUG: Error listing current directory: $e');
        }
      }
    } catch (e) {
      print('DEBUG: Failed to check existing files: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: Row(
          children: [
            const Icon(Icons.error, color: AppColors.error, size: 24),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  void _showFileOptions(File file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              path.basename(file.path),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(
                Icons.info_outline,
                color: AppColors.primaryBlue,
              ),
              title: const Text(
                'File Info',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              onTap: () {
                Navigator.pop(context);
                _showFileInfo(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'Delete File',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteFile(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFileInfo(File file) async {
    try {
      final stat = await file.stat();
      final size = _formatFileSize(stat.size);
      final modified = stat.modified.toString().split('.')[0];

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.backgroundCard,
          title: const Text(
            'File Information',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Name', path.basename(file.path)),
              _buildInfoRow('Size', size),
              _buildInfoRow('Modified', modified),
              _buildInfoRow('Type', _getFileType(path.extension(file.path))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: AppColors.primaryBlue),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      _showErrorDialog('Error', 'Could not get file information');
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        title: const Text(
          'Delete File',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${path.basename(file.path)}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await file.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${path.basename(file.path)} deleted'),
            backgroundColor: AppColors.success,
          ),
        );
        // Refresh the current directory
        if (_currentDirectory != null) {
          await _loadDirectoryContents(_currentDirectory!);
        }
      } catch (e) {
        _showErrorDialog('Delete Error', 'Could not delete file: $e');
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return 'PDF Document';
      case '.docx':
      case '.doc':
        return 'Word Document';
      case '.txt':
        return 'Text File';
      case '.png':
      case '.jpg':
      case '.jpeg':
        return 'Image File';
      default:
        return 'Unknown File';
    }
  }

  Future<int> _getDirectoryItemCount(FileSystemEntity entity) async {
    try {
      if (entity is Directory) {
        final items = await entity.list().toList();
        return items.length;
      }
      return 0;
    } catch (e) {
      print('DEBUG: Error getting directory item count: $e');
      return 0;
    }
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.docx':
      case '.doc':
        return Icons.description;
      case '.txt':
        return Icons.text_snippet;
      case '.png':
      case '.jpg':
      case '.jpeg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildItem(FileSystemEntity item) {
    final isDirectory = item is Directory;
    final name = path.basename(item.path);
    final extension = path.extension(item.path);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: FuturisticCard(
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDirectory
                  ? AppColors.primaryBlue.withOpacity(0.1)
                  : AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isDirectory ? Icons.folder : _getFileIcon(extension),
              color: isDirectory ? AppColors.primaryBlue : AppColors.warning,
              size: 24,
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: isDirectory
              ? FutureBuilder<int>(
                  future: _getDirectoryItemCount(item),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final count = snapshot.data!;
                      return Text(
                        count == 0 ? 'Empty folder' : '$count items',
                        style: const TextStyle(color: AppColors.textSecondary),
                      );
                    }
                    return const Text(
                      'Folder',
                      style: TextStyle(color: AppColors.textSecondary),
                    );
                  },
                )
              : FutureBuilder<FileStat>(
                  future: (item as File).stat(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        _formatFileSize(snapshot.data!.size),
                        style: const TextStyle(color: AppColors.textSecondary),
                      );
                    } else if (snapshot.hasError) {
                      return const Text(
                        'Error loading file info',
                        style: TextStyle(color: AppColors.error),
                      );
                    }
                    return const Text(
                      'Loading...',
                      style: TextStyle(color: AppColors.textSecondary),
                    );
                  },
                ),
          trailing: isDirectory
              ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
              : IconButton(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    if (item is File) _showFileOptions(item);
                  },
                ),
          onTap: () {
            if (item is Directory) {
              print('DEBUG: Tapping on directory: ${item.path}');
              _navigateToDirectory(item);
            } else if (item is File) {
              print('DEBUG: Tapping on file: ${item.path}');
              _showFileOptions(item);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Files',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: _deepScanFiles,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            onPressed: _createTestFile,
          ),
          IconButton(
            icon: const Icon(
              Icons.create_new_folder,
              color: AppColors.textPrimary,
            ),
            onPressed: _createTestDirectory,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () async {
              print('DEBUG: Manual refresh triggered');
              await _forceRefresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Path Breadcrumb
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.backgroundCard,
            child: Row(
              children: [
                Icon(Icons.folder, color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentPath,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryBlue,
                      ),
                    ),
                  )
                : _currentItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _currentPath == 'SmartConverter'
                              ? 'No files saved yet'
                              : 'This folder is empty',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentPath == 'SmartConverter'
                              ? 'Start converting files to see them here'
                              : 'Files will appear here when you save them',
                          style: TextStyle(
                            color: AppColors.textSecondary.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        _currentItems.length +
                        (_currentPath != 'SmartConverter' ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Add "Up" button if not in root
                      if (_currentPath != 'SmartConverter' && index == 0) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: FuturisticCard(
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.textSecondary.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.arrow_upward,
                                  color: AppColors.textSecondary,
                                  size: 24,
                                ),
                              ),
                              title: const Text(
                                '..',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: const Text(
                                'Go up one level',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              onTap: _navigateToParent,
                            ),
                          ),
                        );
                      }

                      final itemIndex = _currentPath != 'SmartConverter'
                          ? index - 1
                          : index;
                      return _buildItem(_currentItems[itemIndex]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
