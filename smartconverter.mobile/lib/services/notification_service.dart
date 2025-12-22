import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import '../constants/app_colors.dart';

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
    debugPrint('🔔 Showing notification for $fileName at $filePath');
    final success = await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'file_save_channel',
        title: 'File Saved Successfully',
        body: 'Your file "$fileName" has been saved to Documents/SmartConverter folder.',
        notificationLayout: NotificationLayout.Default,
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
          label: 'View Folder',
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
        
        // 1. Try generic ACTION_VIEW with inode/directory (very reliable for folder navigation)
        final intentInode = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'file://$folderPath',
          type: 'inode/directory',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        );

        // 2. Try with vnd.android.document/directory
        final intentDocDir = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'file://$folderPath',
          type: 'vnd.android.document/directory',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        );

        // List of common file manager packages 
        final packages = [
          'com.android.documentsui',             // System Documents UI (High Success)
          'com.google.android.apps.nbu.files',   // Files by Google
          'com.vivo.filemanager',                // Vivo (User device)
          'com.android.filemanager',             // AOSP/Generic
          'com.sec.android.app.myfiles',         // Samsung
          'com.mi.android.globalFileexplorer',   // Xiaomi
          'com.coloros.filemanager',             // Oppo
        ];

        // List of directory MIME types to try
        final mimeTypes = [
          'inode/directory',
          'vnd.android.document/directory',
          'resource/folder',
        ];

        bool launched = false;
        
        // 1. Try targeting known packages with multiple MIME types
        for (final pkg in packages) {
          for (final mime in mimeTypes) {
            try {
              final intent = AndroidIntent(
                action: 'android.intent.action.VIEW',
                data: 'file://$folderPath',
                type: mime,
                package: pkg,
                flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_GRANT_READ_URI_PERMISSION],
              );
              debugPrint('🔔 Trying folder intent: pkg=$pkg, mime=$mime');
              await intent.launch();
              launched = true;
              break;
            } catch (e) {
              continue; // Try next MIME type for this package
            }
          }
          if (launched) break; // Found a working combo
        }

        if (launched) return;

        // 2. Generic fallback intent (as a last resort)
        final genericIntent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          data: 'file://$folderPath',
          type: 'inode/directory',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_GRANT_READ_URI_PERMISSION],
        );

        try {
          debugPrint('🔔 Launching generic fallback folder intent...');
          await genericIntent.launch();
          return;
        } catch (e) {
          debugPrint('🔔 Generic intent failed: $e. Falling back to OpenFilex...');
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
      final directoryPath = p.dirname(filePath);
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
