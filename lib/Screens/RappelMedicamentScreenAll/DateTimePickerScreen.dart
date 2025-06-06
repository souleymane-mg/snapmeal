import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;

class DateTimePickerScreen extends StatefulWidget {
  final Function(DateTime?, TimeOfDay, String?) onDateTimeSelected;

  DateTimePickerScreen({required this.onDateTimeSelected});

  @override
  _DateTimePickerScreenState createState() => _DateTimePickerScreenState();
}

class _DateTimePickerScreenState extends State<DateTimePickerScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedRepetition;
  bool _isDateSelected = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sélectionner la date et l\'heure ou la répétition'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(_isDateSelected ? 'Sélectionner une répétition' : 'Sélectionner une date '),
              value: _isDateSelected,
              onChanged: (value) {
                setState(() {
                  _isDateSelected = value;
                  _selectedDate = null;
                  _selectedRepetition = null;
                });
              },
            ),
            if (_isDateSelected)
              ListTile(
                title: Text(_selectedDate != null
                    ? 'Date: ${_selectedDate!.toUtc()}'.split(' ')[0]
                    : 'Choissisez une date'),
                trailing: Icon(Icons.keyboard_arrow_down),
                onTap: _selectDate,
              ),
            if (!_isDateSelected)
              ListTile(
                title: Text('${_selectedRepetition ?? 'Choisissez une répétition'}'),
                trailing: Icon(Icons.keyboard_arrow_down),
                onTap: _selectRepetition,
              ),
            ListTile(
              title: Text('Heure: ${_selectedTime != null ? _selectedTime!.format(context) : 'Sélectionner une heure'}'),
              trailing: Icon(Icons.keyboard_arrow_down),
              onTap: _selectTime,
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (_selectedTime != null && (_selectedDate != null || _selectedRepetition != null)) {
                  widget.onDateTimeSelected(_selectedDate, _selectedTime!, _selectedRepetition);
                  _scheduleAlarm(_selectedDate, _selectedTime!, _selectedRepetition);

                  // Commentaire ou suppression de l'appel à _saveReminderToFirestore
                  // await _saveReminderToFirestore();

                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez sélectionner une heure et une date ou une répétition.')),
                  );
                }
              },
              child: Text('Confirmer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectRepetition() async {
    List<bool> isSelected = [false, false, false, false, false, false, false];
    final List<String> daysOfWeek = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];

    final List<String>? picked = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sélectionner les jours de répétition'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                width: double.maxFinite, // Ajuste la largeur de la boîte de dialogue
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: List.generate(daysOfWeek.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: FilterChip(
                        label: Text(daysOfWeek[index]),
                        selected: isSelected[index],
                        onSelected: (bool selected) {
                          setState(() {
                            isSelected[index] = selected;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                List<String> selectedDays = [];
                for (int i = 0; i < isSelected.length; i++) {
                  if (isSelected[i]) {
                    selectedDays.add(daysOfWeek[i]);
                  }
                }
                Navigator.of(context).pop(selectedDays);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (picked != null && picked.isNotEmpty) {
      String repetition = picked.join(', ');
      setState(() {
        _selectedRepetition = repetition;
      });
    }
  }

  void _scheduleAlarm(DateTime? date, TimeOfDay time, String? repetition) async {
    if (date != null) {
      final tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Alarme',
        'Il est temps!',
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'your_channel_id',
            'your_channel_name',
            channelDescription: 'your_channel_description',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    if (repetition != null) {
      final days = repetition.split(', ').map((day) {
        switch (day) {
          case 'Lun':
            return DateTime.monday;
          case 'Mar':
            return DateTime.tuesday;
          case 'Mer':
            return DateTime.wednesday;
          case 'Jeu':
            return DateTime.thursday;
          case 'Ven':
            return DateTime.friday;
          case 'Sam':
            return DateTime.saturday;
          case 'Dim':
            return DateTime.sunday;
          default:
            return DateTime.monday;
        }
      }).toList();

      for (var day in days) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          day,
          'Alarme répétitive',
          'Il est temps pour votre répétition!',
          _nextInstanceOfDay(time, day),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'repetition_channel_id',
              'repetition_channel_name',
              channelDescription: 'repetition_channel_description',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  tz.TZDateTime _nextInstanceOfDay(TimeOfDay time, int day) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }
    return scheduledDate;
  }

  // Méthode vide pour ne pas ajouter dans Firebase
  Future<void> _saveReminderToFirestore() async {
    // Ne rien faire
  }
}
