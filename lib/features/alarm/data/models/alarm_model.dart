class AlarmModel {
  final String id;
  final String title;
  final String time;
  final bool isEnabled;
  // ضيف السطرين دول هنا 👇
  final String medicationName;
  final String dosageInfo;

  AlarmModel({
    this.id = '',
    this.title = '',
    this.time = '',
    this.isEnabled = true,
    this.medicationName = '', // وضيفهم هنا كمان
    this.dosageInfo = '', // وهنا
  });
}
