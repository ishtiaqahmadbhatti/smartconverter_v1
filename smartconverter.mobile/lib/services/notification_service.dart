import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../constants/app_colors.dart';

class NotificationService {
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
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

    // Check if notifications are allowed
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // Request permission
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // Set up listeners
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    final filePath = receivedAction.payload?['path'];
    if (filePath == null) return;

    if (receivedAction.buttonKeyPressed == 'OPEN' || receivedAction.buttonKeyPressed == 'VIEW') {
      await openFile(filePath);
    }
  }

  static Future<void> openFile(String filePath) async {
    try {
      await OpenFilex.open(filePath);
    } catch (e) {
      debugPrint('Error opening file: $e');
    }
  }

  static Future<void> showFileSavedNotification({
    required String fileName,
    required String filePath,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'file_save_channel',
        title: 'File Saved Successfully ✅',
        body: 'Your file "$fileName" has been saved to SmartConverter folder.',
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
}
