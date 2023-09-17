import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'TimePicker.dart';  // TimePicker.dart 파일에 있는 AlarmSettingPage를 import
import 'AlarmListPage.dart';  // AlarmListPage.dart 파일에 있는 AlarmListPage를 import
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();  // 이 부분을 추가
  var seoul = tz.getLocation('Asia/Seoul');  // 여기에 추가
  tz.setLocalLocation(seoul);  // 여기에 추가
  print('time zone initialized');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
    },
  );

  print("Flutter Local Notifications initialized");
  print('Current local time zone: ${tz.local}');  // 여기에 추가
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AlarmListPage(),
    );
  }
}
