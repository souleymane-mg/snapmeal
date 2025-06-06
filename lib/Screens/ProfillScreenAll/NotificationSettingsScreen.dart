import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _appNotifications = false;
  bool _alarmEnabled = false;
  double _alarmVolume = 0.5;
  String _selectedRingtone = "Default";
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  @override
  void dispose() {
    _stopRingtone();
    super.dispose();
  }

  Future<void> _loadNotificationSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _appNotifications = prefs.getBool('appNotifications') ?? false;
      _alarmEnabled = prefs.getBool('alarmEnabled') ?? false;
      _alarmVolume = prefs.getDouble('alarmVolume') ?? 0.5;
      _selectedRingtone = prefs.getString('selectedRingtone') ?? "Default";
    });
  }

  Future<void> _updateNotificationSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('appNotifications', _appNotifications);
    prefs.setBool('alarmEnabled', _alarmEnabled);
    prefs.setDouble('alarmVolume', _alarmVolume);
    prefs.setString('selectedRingtone', _selectedRingtone);
  }

  void _playRingtone() {
    FlutterRingtonePlayer.playRingtone(volume: _alarmVolume);
    setState(() {
      _isPlaying = true;
    });
  }

  void _stopRingtone() {
    FlutterRingtonePlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _selectRingtone() async {
    // Here you can implement a functionality to select different ringtones
    // For now, we're just toggling between two for simplicity
    setState(() {
      _selectedRingtone = _selectedRingtone == "Default" ? "Alternative" : "Default";
      _playRingtone();
      _updateNotificationSettings();
    });
  }

  Widget _buildSwitch(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (newValue) {
        setState(() {
          onChanged(newValue);
          _updateNotificationSettings();
        });
      },
      activeColor: Color(0xFF00916E),
    );
  }

  Widget _buildSlider(String title, double value, Function(double) onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: value,
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: (value * 100).round().toString(),
        onChanged: (newValue) {
          setState(() {
            onChanged(newValue);
            _updateNotificationSettings();
          });
        },
        activeColor: Color(0xFF00916E),
      ),
    );
  }

  Widget _buildRingtoneSelector() {
    return ListTile(
      title: Text('Faire sonner'),
      subtitle: Text('Sonnerie actuelle : $_selectedRingtone'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: _isPlaying ? Colors.red : Colors.blue,
            ),
            onPressed: () {
              if (_isPlaying) {
                _stopRingtone();
              } else {
                _playRingtone();
              }
            },
          ),
          Icon(Icons.arrow_forward_ios, color: Color(0xFF00916E)),
        ],
      ),
      onTap: _selectRingtone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final isStabilized = width >= 460 && height >= 600;
    final stableWidth = isStabilized ? 460.0 : width;
    final stableHeight = isStabilized ? 600.0 : height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestion De Notification',
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'Poppins-meduims',
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: stableWidth * 0.05),
        child: ListView(
          children: <Widget>[
            SizedBox(height: stableHeight * 0.05),
            _buildSwitch(
              'Notifications de l\'application',
              _appNotifications,
                  (value) => _appNotifications = value,
            ),
            _buildSwitch(
              'Activer les alarmes',
              _alarmEnabled,
                  (value) => _alarmEnabled = value,
            ),
            _buildSlider(
              'Volume de l\'alarme',
              _alarmVolume,
                  (value) {
                _alarmVolume = value;
                if (_isPlaying) {
                  _playRingtone();
                }
              },
            ),
            _buildRingtoneSelector(),
            SizedBox(height: stableHeight * 0.05),
          ],
        ),
      ),
    );
  }
}
