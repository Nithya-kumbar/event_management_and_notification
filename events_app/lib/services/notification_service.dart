// ============================================================
// notification_service.dart
// Local notification + reminder scheduler
// ============================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


class NotificationService {

  static final NotificationService _instance =
      NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();


  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();


  // ------------------------------------------------------------
  // Initialize notification system
  // ------------------------------------------------------------
Future<void> init() async {
  try {
    // Initialize timezone database
    tz.initializeTimeZones();

    // Set local timezone
    tz.setLocalLocation(
      tz.getLocation('Asia/Kolkata'),
    );

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notifications.initialize(settings);

    await createChannel();

    if (!kIsWeb && Platform.isAndroid) {
      await notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  } catch (e) {
    debugPrint('Notification initialization failed: $e');
  }
}


  // ------------------------------------------------------------
  // Create Android notification channel
  // ------------------------------------------------------------


  Future<void> createChannel() async {


    const AndroidNotificationChannel channel =
        AndroidNotificationChannel(
          'event_reminders',
          'Event Reminders',
          description:
              'Reminders for college events',
          importance: Importance.max,
        );


    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          channel,
        );

  }





  // ------------------------------------------------------------
  // Parse time like "09:00 AM"
  // ------------------------------------------------------------


  DateTime parseEventTime(
      DateTime date,
      String time,
  ) {


    final parts =
        time.trim().split(" ");


    final hm =
        parts[0].split(":");


    int hour =
        int.parse(hm[0]);

    int minute =
        int.parse(hm[1]);


    final period =
        parts[1].toUpperCase();



    if(period == "PM" && hour != 12){
      hour += 12;
    }


    if(period == "AM" && hour == 12){
      hour = 0;
    }



    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );

  }






  // ------------------------------------------------------------
  // Schedule all reminders for an event
  //
  // 1 day before
  // 1 hour before
  // event time
  // ------------------------------------------------------------


  Future<void> scheduleEventReminder({

    required int eventId,
    required String title,
    required DateTime eventDate,
    required String eventTime,

  }) async {


    final DateTime eventDateTime =
        parseEventTime(
          eventDate,
          eventTime,
        );



    final reminders = [

      {
        "time":
          eventDateTime.subtract(
            const Duration(days:1),
          ),
        "message":
          "$title is tomorrow."
      },


      {
        "time":
          eventDateTime.subtract(
            const Duration(hours:1),
          ),
        "message":
          "$title starts in 1 hour."
      },


      {
        "time":
          eventDateTime,
        "message":
          "$title is starting now."
      },

    ];



    for(int i=0;i<reminders.length;i++){


      final reminder =
          reminders[i];


      final DateTime time =
          reminder["time"] as DateTime;



      // don't schedule old notifications
      if(time.isBefore(DateTime.now())){
        continue;
      }



      await notifications.zonedSchedule(

        eventId * 10 + i,

        title,

        reminder["message"] as String,


        tz.TZDateTime.from(
          time,
          tz.local,
        ),


        const NotificationDetails(

          android:
            AndroidNotificationDetails(

              'event_reminders',

              'Event Reminders',

              channelDescription:
                'College event reminders',

              importance:
                Importance.max,

              priority:
                Priority.high,

            ),

          iOS:
            DarwinNotificationDetails(),

        ),



        androidScheduleMode:
          AndroidScheduleMode
              .exactAllowWhileIdle,

      );


    }

  }







  // ------------------------------------------------------------
  // Remove all old reminders
  // ------------------------------------------------------------


  Future<void> cancelAllReminders() async {

    await notifications.cancelAll();

  }








  // ------------------------------------------------------------
  // Cancel one event
  // ------------------------------------------------------------


  Future<void> cancelEvent(
      int eventId
  ) async {


    await notifications.cancel(
      eventId * 10,
    );


    await notifications.cancel(
      eventId * 10 + 1,
    );


    await notifications.cancel(
      eventId * 10 + 2,
    );

  }




}