import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'AlarmInfo.dart';
import 'main.dart';  // main.dart 파일에서 flutterLocalNotificationsPlugin 객체를 가져오기 위해

class AlarmSettingPage extends StatefulWidget {
  @override
  _AlarmSettingPageState createState() => _AlarmSettingPageState();
}

class _AlarmSettingPageState extends State<AlarmSettingPage> {
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedTone = 'ala_1';
  int alarmID = 0;  // 알람 ID를 저장하는 변수 추가

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
      });
  }

  Future<void> _scheduleAlarm(TimeOfDay time, String tone) async {
    final DateTime now = DateTime.now();
    final DateTime scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alarm_id',
      'alarm_name',
      'alarm_description',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound(selectedTone),
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.schedule(
      alarmID,  // 고유 ID 사용
      'Alarm',
      tone,
      scheduledDate,
      platformChannelSpecifics,
    );

    alarmID++;  // 알람을 설정할 때마다 ID 증가
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm Setting'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _selectTime(context),
              child: Text('Select time: ${selectedTime.format(context)}'),
            ),
            DropdownButton<String>(
              value: selectedTone,
              items: <String>['ala_1', 'ala_2', 'ala_3']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTone = newValue!;
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                await _scheduleAlarm(selectedTime, selectedTone);
                AlarmInfo newAlarm = AlarmInfo(
                  time: selectedTime,
                  tone: selectedTone,
                );
                Navigator.pop(context, newAlarm);
              },
              child: Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}