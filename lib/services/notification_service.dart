import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> showTestNotification() async {
  await _notifications.show(
    999,
    "Test Notifikasi",
    "Selamat Datang!",
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'planner_channel',
        'Planner Notifications',
        channelDescription: 'Notifikasi pengingat planner',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
  );
  print("Test notifikasi dikirim");
}

  static Future<void> init() async {
    tz_data.initializeTimeZones();;
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: android);

    await _notifications.initialize(settings);

    await NotificationService.showTestNotification();

    // minta permission
    await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final granted = await _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();

    print("Permission granted: $granted");
  }

  static Future<void> schedulePlannerNotification({
    required int id,
    required String title,
    required String date, // format dd/mm/yyyy
    required String time, // format hh:mm
  }) async {
    tz_data.initializeTimeZones();
    
    final String localTz = DateTime.now().timeZoneName;
    try {
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta')); // fallback
    }

    final parts = date.split('/');
    final timeParts = time.split(':');

    // buat objek TZDateTime untuk waktu notifikasi
    final scheduledTime = tz.TZDateTime(
      tz.local,
      int.parse(parts[2]), // index ke 2 dr depan, bagian tahun (yyyy)
      int.parse(parts[1]), // index ke 1 dr depan, bagian bulan (mm)
      int.parse(parts[0]), // 0 dr depan, bagian hari (dd)
      int.parse(timeParts[0]), // 0 dr depan, bagian jam (hh)
      int.parse(timeParts[1]), // 1 dr depan, bagian menit (mm)
    ).subtract(const Duration(hours: 1)); // notif masuk 1 jam sebelum acara (waktu acara - 1 jam)

    // kalau waktunya sudah lewat local time, skip
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    try {
      await _notifications.zonedSchedule(
        id,
        "MoodMate Reminder 🗓️",
        "$title dimulai dalam 1 jam!",
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'planner_channel',
            'Planner Notifications',
            channelDescription: 'Notifikasi pengingat planner',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      //debug
      print("zonedSchedule berhasil dipanggil untuk id: $id");
    } catch (e) {
      print("ERROR zonedSchedule: $e");
    }
    // debug print
    print("Waktu sekarang: ${tz.TZDateTime.now(tz.local)}");
    print("Waktu notifikasi: $scheduledTime");
    print("Sudah lewat: ${scheduledTime.isBefore(tz.TZDateTime.now(tz.local))}");
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}