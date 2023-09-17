import 'package:flutter/material.dart';
import 'AlarmInfo.dart';
import 'TimePicker.dart';
import 'main.dart';  // flutterLocalNotificationsPlugin가 있는 곳으로 추정

class AlarmListPage extends StatefulWidget {
  @override
  _AlarmListPageState createState() => _AlarmListPageState();
}

class _AlarmListPageState extends State<AlarmListPage> {
  List<AlarmInfo> alarms = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm List'),
      ),
      body: alarms.isEmpty
          ? Center(
        child: Text('No alarms yet!'),
      )
          : ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          final alarm = alarms[index];
          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          final enabledDays = List.generate(7, (i) => alarm.repeatDays[i] ? days[i] : null).where((day) => day != null).join(', ');
          return ListTile(
            title: Text('Alarm at ${alarm.time.format(context)}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tone: ${alarm.tone}'),
                Text('Days: $enabledDays'),  // 여기에 요일을 표시
                ElevatedButton(
                  onPressed: () {
                    flutterLocalNotificationsPlugin.cancel(alarm.id);  // 알람 취소
                    setState(() {
                      alarms.removeAt(index);  // 리스트에서 제거
                    });
                  },
                  child: Text('Delete'),
                ),
              ],
            ),

            trailing: Switch(
              value: alarm.isActive, // isActive 필드 사용
              onChanged: (value) {
                setState(() {
                  alarm.isActive = value; // 스위치 상태 업데이트
                });
              },
            ),
            onTap: () async {
              final updatedAlarm = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlarmSettingPage(
                    existingAlarm: alarm, // 기존 알람 정보 전달
                  ),
                ),
              ) as AlarmInfo?;
              if (updatedAlarm != null) {
                setState(() {
                  alarms[index] = updatedAlarm; // 알람 정보 업데이트
                });
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newAlarm = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AlarmSettingPage()),
          ) as AlarmInfo?;
          if (newAlarm != null) {
            setState(() {
              alarms.add(newAlarm);
            });
          }
        },
        tooltip: 'Add Alarm',
        child: Icon(Icons.add),
      ),
    );
  }
}
