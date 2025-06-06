import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medecineproject/Screens/SplashScreenAll/SplashScreen2.dart';
import 'package:medecineproject/providers/MedicationProvider.dart';
import './Screens/ProfillScreenAll/theme_provider.dart'; // Import du theme_provider
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medecineproject/BottomBar/BottomBarScreen.dart';
import 'package:medecineproject/Screens/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medecineproject/Services/alarm_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';
import 'package:medecineproject/services/notification_service.dart'; // Import the notification service

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('fr_FR', null);
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAKoslPX5jsl07vFR7IcNHgnWPaYDvuczY",
        authDomain: "malikouramedecine.firebaseapp.com",
        projectId: "malikouramedecine",
        storageBucket: "malikouramedecine.appspot.com",
        messagingSenderId: "877714545403",
        appId: "1:877714545403:web:d13129b8550edbcc42ee5e",
      ),

    );

  await _configureLocalTimeZone();

  runApp(MyApp());
  AlarmService();
  NotificationService(); // Initialize notification service
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('UTC'));
}

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  MyApp() {
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'E_medecine',
            theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
            home: HomeSelector(),
          );
        },
      ),
    );
  }
}

class HomeSelector extends StatefulWidget {
  @override
  _HomeSelectorState createState() => _HomeSelectorState();
}

class _HomeSelectorState extends State<HomeSelector> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => BottomBarScreen()),
      );
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool showSplash2 = prefs.getBool('showSplash2') ?? true;

      if (showSplash2) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => FoochiOnboardingView()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Loginscreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}




