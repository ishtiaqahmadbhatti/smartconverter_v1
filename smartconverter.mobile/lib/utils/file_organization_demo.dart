import '../app_modules/imports_module.dart';

/// Demo class to showcase the file organization system
class FileOrganizationDemo {
  /// Test the file organization system
  static Future<void> testFileOrganization() async {
    print('🗂️  Testing SmartConverter File Organization System...\n');

    try {
      // Test 1: Get main SmartConverter directory
      print('📁 Test 1: Getting SmartConverter main directory...');
      final smartConverterDir = await FileManager.getSmartConverterDirectory();
      print('✅ SmartConverter directory: ${smartConverterDir.path}\n');

      // Test 2: Get tool-specific directories
      print('📁 Test 2: Creating tool-specific directories...');
      final addPageNumbersDir = await FileManager.getAddPageNumbersDirectory();
      final mergePdfDir = await FileManager.getMergePdfDirectory();
      final pdfToWordDir = await FileManager.getPdfToWordDirectory();

      print('✅ AddPageNumbers: ${addPageNumbersDir.path}');
      print('✅ MergePDF: ${mergePdfDir.path}');
      print('✅ PdfToWord: ${pdfToWordDir.path}\n');

      // Test 3: Generate timestamp filenames
      print('📝 Test 3: Generating timestamp filenames...');
      final numberedPdf = FileManager.generateTimestampFilename(
        'numbered',
        'pdf',
      );
      final mergedPdf = FileManager.generateTimestampFilename('merged', 'pdf');
      final convertedDoc = FileManager.generateTimestampFilename(
        'converted',
        'docx',
      );

      print('✅ Numbered PDF: $numberedPdf');
      print('✅ Merged PDF: $mergedPdf');
      print('✅ Converted DOC: $convertedDoc\n');

      // Test 4: Get folder structure info
      print('📊 Test 4: Getting folder structure info...');
      final folderInfo = await FileManager.getFolderStructureInfo();

      if (folderInfo.containsKey('error')) {
        print('❌ Error: ${folderInfo['error']}');
      } else {
        print('✅ Main path: ${folderInfo['mainPath']}');
        print('✅ Total folders: ${folderInfo['totalFolders']}');
        print('📁 Folders:');

        final folders = folderInfo['folders'] as Map<String, dynamic>;
        folders.forEach((folderName, info) {
          print('   - $folderName: ${info['fileCount']} files');
        });
      }

      print('\n🎉 File organization system test completed successfully!');
    } catch (e) {
      print('❌ Error testing file organization: $e');
    }
  }

  /// Show the expected folder structure
  static void showExpectedStructure() {
    print('🗂️  Expected SmartConverter Folder Structure:\n');
    print('Documents/');
    print('└── SmartConverter/');
    print('    ├── AddPageNumbers/');
    print('    │   └── numbered_YYYYMMDD_HHMM.pdf');
    print('    ├── MergePDF/');
    print('    │   └── merged_YYYYMMDD_HHMM.pdf');
    print('    ├── SplitPDF/');
    print('    │   └── split_YYYYMMDD_HHMM.pdf');
    print('    ├── CompressPDF/');
    print('    │   └── compressed_YYYYMMDD_HHMM.pdf');
    print('    ├── PdfToWord/');
    print('    │   └── converted_YYYYMMDD_HHMM.docx');
    print('    ├── WordToPdf/');
    print('    │   └── converted_YYYYMMDD_HHMM.pdf');
    print('    ├── ImageToPdf/');
    print('    │   └── converted_YYYYMMDD_HHMM.pdf');
    print('    ├── PdfToImage/');
    print('    │   └── converted_YYYYMMDD_HHMM.png');
    print('    ├── RotatePDF/');
    print('    │   └── rotated_YYYYMMDD_HHMM.pdf');
    print('    ├── ProtectPDF/');
    print('    │   └── protected_YYYYMMDD_HHMM.pdf');
    print('    └── UnlockPDF/');
    print('        └── unlocked_YYYYMMDD_HHMM.pdf');
    print(
      '\n📝 Note: YYYYMMDD_HHMM represents timestamp (Year-Month-Day_Hour-Minute)',
    );
  }
}
