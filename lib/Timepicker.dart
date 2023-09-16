import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'AlarmInfo.dart';
import 'main.dart';

class AlarmSettingPage extends StatefulWidget {
  @override
  _AlarmSettingPageState createState() => _AlarmSettingPageState();
}

class _AlarmSettingPageState extends State<AlarmSettingPage> {
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedTone = 'ala_1';
  List<bool> isSelected = [false, false, false, false, false, false, false];
  int alarmID = 0;

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

    await flutterLocalNotificationsPlugin.schedule(
      alarmID,
      'Alarm',
      tone,
      scheduledDate,
      platformChannelSpecifics,
    );

    alarmID++;
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
                onPressed: () async {
                  await _scheduleAlarm(selectedTime, selectedTone);
                  AlarmInfo newAlarm = AlarmInfo(
                    time: selectedTime,
                    tone: selectedTone,
                    repeatDays: isSelected,
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
      ),
    );
  }
}
