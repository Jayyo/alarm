import 'package:flutter/material.dart';


class AlarmInfo {
  TimeOfDay time;
  String tone;
  List<bool> repeatDays;
  bool isActive;  // 추가
  AlarmInfo({required this.time, required this.tone, required this.repeatDays, this.isActive = true});
}
