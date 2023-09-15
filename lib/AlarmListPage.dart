import 'package:flutter/material.dart';
import 'AlarmInfo.dart';
import 'TimePicker.dart';

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
          return ListTile(
            title: Text('Alarm at ${alarm.time.format(context)}'),
            subtitle: Text('Tone: ${alarm.tone}'),
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
