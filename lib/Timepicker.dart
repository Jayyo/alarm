import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'AlarmInfo.dart';
import 'main.dart';
import 'package:timezone/timezone.dart' as tz;


class AlarmSettingPage extends StatefulWidget {
  final AlarmInfo? existingAlarm;  // 기존 알람 정보를 받을 변수 추가

  AlarmSettingPage({this.existingAlarm});
  @override
  _AlarmSettingPageState createState() => _AlarmSettingPageState();
}

class _AlarmSettingPageState extends State<AlarmSettingPage> {
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedTone = 'ala_1';
  List<bool> isSelected = [false, false, false, false, false, false, false];
  int alarmID = 0;

  @override
  void initState() {
    super.initState();
    if (widget.existingAlarm != null) {  // 기존 알람이 있다면 초기 값을 설정
      selectedTime = widget.existingAlarm!.time;
      selectedTone = widget.existingAlarm!.tone;
      isSelected = widget.existingAlarm!.repeatDays;
    } else {
      selectedTime = TimeOfDay.now();
      selectedTone = 'ala_1';
      isSelected = [false, false, false, false, false, false, false];
    }
  }

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

  Future<void> _scheduleAlarm(TimeOfDay time, String tone, List<bool> repeatDays) async {
    try {
      final DateTime now = DateTime.now();
      print("Current time: $now");
      int todayWeekday = now.weekday -1;
      print("Today's weekday index : $todayWeekday");

      for (int i = 0; i < repeatDays.length; i++) {
        print("Checking repeatDay index : $i, value : ${repeatDays[i]}");
        if (repeatDays[i]) {
          int daysToAdd = (i - todayWeekday + 7) % 7;
          print("daysToAdd: $daysToAdd");

          final DateTime scheduledDate = DateTime(now.year, now.month, now.day + daysToAdd, time.hour, time.minute);

          if (daysToAdd == 0 && scheduledDate.isBefore(now)) {
            if (scheduledDate.isBefore(now)) {
              daysToAdd = 7;
            }
          }

          final DateTime newScheduledDate = DateTime(now.year, now.month, now.day + daysToAdd, time.hour, time.minute);
          print('Days to add for index $i: $daysToAdd');

          DateTime adjustedSchedule = scheduledDate;

          print("Current time: $now");
          print("Scheduled Date: $scheduledDate");
          print('Scheduling alarm with tone: $tone');

          if (scheduledDate.isAfter(now) || scheduledDate.isAtSameMomentAs(now)) {
            adjustedSchedule = scheduledDate;
          } else {
            adjustedSchedule = scheduledDate.add(Duration(days: 7));
          }

          String channelId = 'alarm_channel_${DateTime.now().millisecondsSinceEpoch}'; // Unique channel ID

          var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            channelId,
            'Alarm channel',
            'Channel for Alarm notification',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound(selectedTone),
          );

          var platformChannelSpecifics = NotificationDetails(
            android: androidPlatformChannelSpecifics,
          );

          await flutterLocalNotificationsPlugin.zonedSchedule(
            alarmID,
            'Alarm',
            tone,
            tz.TZDateTime.from(adjustedSchedule, tz.local),  // UTC 대신 local 사용
            platformChannelSpecifics,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            androidAllowWhileIdle: true,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,  // 매주 같은 요일에 알람이 울림
          );
          print("Alarm with ID $alarmID scheduled for ${tz.TZDateTime.from(adjustedSchedule, tz.local)}");  // Debug log
          print("Alarm scheduled for ${tz.TZDateTime.from(adjustedSchedule, tz.local)}");  // Debug log
          print('Alarm scheduled with tone: $tone');  // 추가할 로그

          alarmID++;
        }
      }
    } catch (e) {
      print("Error while scheduling alarm: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm Setting'),
      ),
      body: SingleChildScrollView(
        child: Center(
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
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: isSelected.length,
                itemBuilder: (BuildContext context, int index) {
                  return CheckboxListTile(
                    title: Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index]),
                    value: isSelected[index],
                    onChanged: (bool? value) {
                      setState(() {
                        isSelected[index] = value!;
                      });
                    },
                  );
                },
              ),
              ElevatedButton(
                onPressed: isSelected.contains(true) ? () async {
                  await _scheduleAlarm(selectedTime, selectedTone, isSelected);
                  AlarmInfo newAlarm = AlarmInfo(
                    time: selectedTime,
                    tone: selectedTone,
                    repeatDays: isSelected,
                    id : alarmID,
                  );
                  Navigator.pop(context, newAlarm);
                } : null,  // 요일이 하나도 선택되지 않았다면 null
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
      ),
    );
  }
}
