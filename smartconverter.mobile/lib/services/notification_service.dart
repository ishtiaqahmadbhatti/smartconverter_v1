import '../app_modules/imports_module.dart';

class NotificationService {
  static Future<void> initialize() async {
    debugPrint('🔔 Initializing NotificationService...');
    try {
      final initialized = await AwesomeNotifications().initialize(
        'resource://mipmap/ic_launcher',
        [
          NotificationChannel(
            channelKey: 'file_save_channel',
            channelName: 'File Saving Notifications',
            channelDescription: 'Notification channel for file saving events',
            defaultColor: AppColors.primaryBlue,
            ledColor: Colors.white,
            importance: NotificationImportance.High,
            channelShowBadge: true,
            onlyAlertOnce: true,
            playSound: true,
            criticalAlerts: true,
          )
        ],
        debug: true,
      );
      debugPrint('🔔 AwesomeNotifications initialized: $initialized');

      // Check if notifications are allowed
      bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
      debugPrint('🔔 Notification allowed: $isAllowed');
      if (!isAllowed) {
        debugPrint('🔔 Requesting notification permissions...');
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }

      // Set up listeners
      AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onNotificationCreatedMethod: onNotificationCreatedMethod,
        onNotificationDisplayedMethod: onNotificationDisplayedMethod,
        onDismissActionReceivedMethod: onDismissActionReceivedMethod,
      );
    } catch (e) {
      debugPrint('🔔 Error initializing AwesomeNotifications: $e');
    }
  }

  static Future<void> showFileSavedNotification({
    required String fileName,
    required String filePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final allNotifications = prefs.getBool('all_notifications') ?? true;
    final conversionAlerts = prefs.getBool('conversion_alerts') ?? true;

    if (!allNotifications || !conversionAlerts) {
      debugPrint('🔔 Skipping notification: allNotifications=$allNotifications, conversionAlerts=$conversionAlerts');
      return;
    }

    debugPrint('🔔 Showing notification for $fileName at $filePath');
    final relativePath = filePath.replaceFirst('/storage/emulated/0/', '');
    final folderPath = dirname(relativePath);
    
    final success = await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'file_save_channel',
        title: 'File Saved Successfully',
        body: 'Your file "$fileName" has been saved to $folderPath folder.',
        notificationLayout: NotificationLayout.BigText,
        payload: {'path': filePath},
        category: NotificationCategory.Status,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'OPEN',
          label: 'Open File',
          actionType: ActionType.Default,
          color: AppColors.primaryBlue,
        ),
        NotificationActionButton(
          key: 'VIEW',
          label: 'Open Folder',
          actionType: ActionType.Default,
        ),
      ],
    );
  }

  static Future<void> openFile(String path) async {
    debugPrint('🔔 Attempting to open path: $path');
    try {
      final isDir = await Directory(path).exists();
      
      if (Platform.isAndroid && isDir) {
        debugPrint('🔔 Path is a directory, using precise Android Intents');
        
        // Ensure path ends with a slash for better explorer identification
        final folderPath = path.endsWith('/') ? path : '$path/';
        
        // 1. Precise DocumentsContract URI for system file manager (Highest success for "Direct Open")
        // primary:Documents/SmartConverter/JSONConversion/pdf-to-json
        String relativePath = folderPath.replaceAll('/storage/emulated/0/', '');
        String encodedPath = relativePath.replaceAll('/', '%2F');
        String docUri = 'content://com.android.externalstorage.documents/document/primary%3A$encodedPath';
        
        // 2. FileProvider URI for other file managers
        // authority matching AndroidManifest.xml: com.example.smartconverter.fileprovider
        String authority = 'com.example.smartconverter.fileprovider';
        String fileProviderUri = 'content://$authority/external_files/$relativePath';

        final uris = [docUri, fileProviderUri];
        final packages = [
          'com.android.documentsui',             // System Documents UI
          'com.google.android.apps.nbu.files',   // Files by Google
          'com.vivo.filemanager',                // Vivo
          'com.android.filemanager',             // Generic
          'com.sec.android.app.myfiles',         // Samsung
        ];

        final mimeTypes = [
          'vnd.android.document/directory',
          'inode/directory',
          'resource/folder',
        ];

        bool launched = false;
        
        // Try combinations with content URIs
        for (final uri in uris) {
          for (final pkg in packages) {
            for (final mime in mimeTypes) {
              try {
                final intent = AndroidIntent(
                  action: 'android.intent.action.VIEW',
                  data: uri,
                  type: mime,
                  package: pkg,
                  flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_GRANT_READ_URI_PERMISSION],
                );
                await intent.launch();
                launched = true;
                debugPrint('🔔 Success opening folder with: pkg=$pkg, uri=$uri');
                break;
              } catch (e) {
                continue;
              }
            }
            if (launched) break;
          }
          if (launched) break;
        }

        if (launched) return;

        // Fallback to generic ACTION_VIEW with content URI
        try {
          final intent = AndroidIntent(
            action: 'android.intent.action.VIEW',
            data: fileProviderUri,
            type: 'vnd.android.document/directory',
            flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_GRANT_READ_URI_PERMISSION],
          );
          await intent.launch();
          return;
        } catch (e) {
          debugPrint('🔔 Generic content intent failed, trying OpenFilex...');
        }
      }

      // For files or fallback for directories
      final result = await OpenFilex.open(path);
      debugPrint('🔔 OpenFilex result: ${result.type} - ${result.message}');
    } catch (e) {
      debugPrint('🔔 Error opening path: $e');
    }
  }
}

/// Use this method to detect when a new notification or a schedule is created
@pragma("vm:entry-point")
Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification) async {
  // Your code goes here
}

/// Use this method to detect every time that a new notification is displayed
@pragma("vm:entry-point")
Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification) async {
  // Your code goes here
}

/// Use this method to detect if the user dismissed a notification
@pragma("vm:entry-point")
Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction) async {
  // Your code goes here
}

/// Use this method to detect when the user taps on a notification or action button
@pragma("vm:entry-point")
Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction) async {
  debugPrint('🔔 Notification Action Received: ${receivedAction.buttonKeyPressed}');
  
  final filePath = receivedAction.payload?['path'];
  if (filePath == null) {
    debugPrint('🔔 Error: No file path in notification payload');
    return;
  }

  debugPrint('🔔 Payload path: $filePath');

  try {
    if (receivedAction.buttonKeyPressed == 'VIEW') {
      debugPrint('🔔 Action: VIEW (Open Folder)');
      final directoryPath = dirname(filePath);
      debugPrint('🔔 Opening directory: $directoryPath');
      await NotificationService.openFile(directoryPath);
    } else {
      // Handle 'OPEN' button OR clicking the notification body (buttonKeyPressed is empty)
      debugPrint('🔔 Action: OPEN or BODY CLICK (Open File)');
      await NotificationService.openFile(filePath);
    }
  } catch (e) {
    debugPrint('🔔 Error handling notification action: $e');
  }
}
