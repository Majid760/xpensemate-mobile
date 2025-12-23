// import 'dart:convert';
// import 'dart:io';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:xpensemate/core/utils/app_logger.dart';

// class NotificationService {
//   factory NotificationService() => _instance;
//   NotificationService._internal();
//   static final NotificationService _instance = NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   // Notification channels
//   static const String _defaultChannelId = 'default_channel';
//   static const String _highPriorityChannelId = 'high_priority_channel';
//   static const String _scheduledChannelId = 'scheduled_channel';

//   bool _isInitialized = false;

//   /// Initialize the notification service
//   Future<void> initialize() async {
//     if (_isInitialized) return;

//     await _initializeLocalNotifications();
//     await _initializePushNotifications();
//     await _setupNotificationChannels();

//     _isInitialized = true;
//     logI('NotificationService initialized successfully');
//   }

//   /// Initialize local notifications
//   Future<void> _initializeLocalNotifications() async {
//     // Initialize timezone data
//     tz.initializeTimeZones();

//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

//     const iosSettings = DarwinInitializationSettings();

//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _localNotifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );
//   }

//   /// Initialize push notifications (FCM)
//   Future<void> _initializePushNotifications() async {
//     // Request permission for iOS
//     final settings = await _firebaseMessaging.requestPermission();

//     logI('Push notification permission: ${settings.authorizationStatus}');

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

//     // Handle background messages
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

//     // Handle terminated app messages
//     await _handleTerminatedAppMessage();
//   }

//   /// Setup notification channels for Android
//   Future<void> _setupNotificationChannels() async {
//     if (Platform.isAndroid) {
//       final androidPlugin =
//           _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

//       if (androidPlugin != null) {
//         // Default channel
//         await androidPlugin.createNotificationChannel(
//           const AndroidNotificationChannel(
//             _defaultChannelId,
//             'Default Notifications',
//             description: 'Default notification channel',
//           ),
//         );

//         // High priority channel
//         await androidPlugin.createNotificationChannel(
//           const AndroidNotificationChannel(
//             _highPriorityChannelId,
//             'High Priority Notifications',
//             description: 'High priority notification channel',
//             importance: Importance.high,
//           ),
//         );

//         // Scheduled channel
//         await androidPlugin.createNotificationChannel(
//           const AndroidNotificationChannel(
//             _scheduledChannelId,
//             'Scheduled Notifications',
//             description: 'Scheduled notification channel',
//           ),
//         );
//       }
//     }
//   }

//   /// Show a simple local notification
//   Future<void> showLocalNotification({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//     NotificationPriority priority = NotificationPriority.normal,
//   }) async {
//     final channelId = priority == NotificationPriority.high ? _highPriorityChannelId : _defaultChannelId;

//     final androidDetails = AndroidNotificationDetails(
//       channelId,
//       priority == NotificationPriority.high ? 'High Priority Notifications' : 'Default Notifications',
//       importance: priority == NotificationPriority.high ? Importance.high : Importance.defaultImportance,
//       priority: priority == NotificationPriority.high ? Priority.high : Priority.defaultPriority,
//     );

//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     final notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _localNotifications.show(
//       id,
//       title,
//       body,
//       notificationDetails,
//       payload: payload,
//     );
//   }

//   /// Schedule a local notification
//   Future<void> scheduleLocalNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//     String? payload,
//   }) async {
//     final scheduledTZ = tz.TZDateTime.from(
//       scheduledDate,
//       tz.local,
//     );

//     const androidDetails = AndroidNotificationDetails(
//       _scheduledChannelId,
//       'Scheduled Notifications',
//     );

//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     const notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _localNotifications.zonedSchedule(
//       id,
//       title,
//       body,
//       scheduledTZ,
//       notificationDetails,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       payload: payload,
//     );
//   }

//   /// Schedule a repeating local notification
//   Future<void> scheduleRepeatingNotification({
//     required int id,
//     required String title,
//     required String body,
//     required RepeatInterval repeatInterval,
//     String? payload,
//   }) async {
//     const androidDetails = AndroidNotificationDetails(
//       _scheduledChannelId,
//       'Scheduled Notifications',
//     );

//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     const notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _localNotifications.zonedSchedule(
//       id,
//       title,
//       body,
//       tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
//       notificationDetails,
//       payload: payload,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     );
//   }

//   /// Cancel a specific notification
//   Future<void> cancelNotification(int id) async {
//     await _localNotifications.cancel(id);
//   }

//   /// Cancel all notifications
//   Future<void> cancelAllNotifications() async {
//     await _localNotifications.cancelAll();
//   }

//   /// Get pending notifications
//   Future<List<PendingNotificationRequest>> getPendingNotifications() =>
//       _localNotifications.pendingNotificationRequests();

//   /// Get FCM token
//   Future<String?> getFCMToken() => _firebaseMessaging.getToken();

//   /// Subscribe to a topic
//   Future<void> subscribeToTopic(String topic) async {
//     await _firebaseMessaging.subscribeToTopic(topic);
//     logI('Subscribed to topic: $topic');
//   }

//   /// Unsubscribe from a topic
//   Future<void> unsubscribeFromTopic(String topic) async {
//     await _firebaseMessaging.unsubscribeFromTopic(topic);
//     logI('Unsubscribed from topic: $topic');
//   }

//   /// Handle foreground messages
//   void _handleForegroundMessage(RemoteMessage message) {
//     logI('Received foreground message: ${message.messageId}');

//     // Show local notification for foreground messages
//     showLocalNotification(
//       id: message.hashCode,
//       title: message.notification?.title ?? 'New Message',
//       body: message.notification?.body ?? 'You have a new message',
//       payload: jsonEncode(message.data),
//       priority: NotificationPriority.high,
//     );
//   }

//   /// Handle background messages (app opened from notification)
//   void _handleBackgroundMessage(RemoteMessage message) {
//     logI('App opened from background notification: ${message.messageId}');
//     _processNotificationData(message.data);
//   }

//   /// Handle messages when app is terminated
//   Future<void> _handleTerminatedAppMessage() async {
//     final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

//     if (initialMessage != null) {
//       logI('App opened from terminated state: ${initialMessage.messageId}');
//       _processNotificationData(initialMessage.data);
//     }
//   }

//   /// Handle notification tap (local notifications)
//   void _onNotificationTapped(NotificationResponse response) {
//     logI('Notification tapped: ${response.id}');

//     if (response.payload != null) {
//       try {
//         final data = jsonDecode(response.payload!);
//         _processNotificationData(data as Map<String, dynamic>);
//       } on Exception catch (e) {
//         logE('Error parsing notification payload: $e');
//       }
//     }
//   }

//   /// Process notification data and navigate accordingly
//   void _processNotificationData(Map<String, dynamic> data) {
//     // Handle navigation based on notification data
//     // You can customize this based on your app's requirements
//     logI('Processing notification data: $data');

//     // Example: Navigate to specific screen based on notification type
//     final type = data['type'];
//     final screenId = data['screen_id'];

//     if (type != null && screenId != null) {
//       // Navigate to the appropriate screen
//       // NavigationService.navigateTo(screenId, data);
//     }
//   }

//   /// Check if notifications are enabled
//   Future<bool> areNotificationsEnabled() async {
//     if (Platform.isAndroid) {
//       final androidPlugin =
//           _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
//       return await androidPlugin?.areNotificationsEnabled() ?? false;
//     } else if (Platform.isIOS) {
//       final result = await _localNotifications
//           .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(
//             alert: true,
//             badge: true,
//             sound: true,
//           );
//       return result ?? false;
//     }
//     return false;
//   }

//   /// Request notification permissions
//   Future<bool> requestPermissions() async {
//     if (Platform.isAndroid) {
//       final androidPlugin =
//           _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

//       return await androidPlugin?.requestNotificationsPermission() ?? false;
//     } else if (Platform.isIOS) {
//       final result = await _localNotifications
//           .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
//           ?.requestPermissions(
//             alert: true,
//             badge: true,
//             sound: true,
//           );
//       return result ?? false;
//     }
//     return false;
//   }
// }

// /// Notification priority enum
// enum NotificationPriority {
//   normal,
//   high,
// }

// /// Background message handler (must be top-level function)
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // print('Handling background message: ${message.messageId}');
//   // Handle background message processing here
// }
