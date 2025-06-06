import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'ModifierProfileScreen.dart';
import 'GererCompteScreen.dart';
import '../ProfillScreenAll/theme_provider.dart'; // Import du ThemeProvider

// Classe principale de l'écran des paramètres
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool valNotify1 = true;
  bool valNotify2 = false;
  String selectedLanguage = "Français";
  String selectedRegion = "Afrique";

  void onChangeFunction1(bool newValue1) {
    setState(() {
      valNotify1 = newValue1;
    });
  }

  void onChangeFunction2(bool newValue2) {
    setState(() {
      valNotify2 = newValue2;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var isPortrait = screenSize.height > screenSize.width;
    var padding = isPortrait ? 20.0 : 30.0;
    var fontSize = isPortrait ? 20.0 : 18.0;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Paramètres',
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'Poppins-meduims',
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.iconTheme.color,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(padding),
        child: ListView(
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/Icons/compte.svg',
                  width: isPortrait ? 30 : 25,
                  height: isPortrait ? 40 : 35,
                  color: theme.iconTheme.color,
                ),
                SizedBox(width: 10),
                Text(
                  "Compte",
                  style: TextStyle(
                    fontSize: isPortrait ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyText1?.color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            buildCompteOption(
                context, "Modifier Profil", ModifierProfileScreen()),
            buildCompteOption(context, "Gérer le Compte", GererCompteScreen()),
            SizedBox(height: 50),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/Icons/notification.svg',
                  width: isPortrait ? 30 : 25,
                  height: isPortrait ? 40 : 35,
                  color: theme.iconTheme.color,
                ),
                SizedBox(width: 10),
                Text(
                  "Notifications",
                  style: TextStyle(
                    fontSize: isPortrait ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyText1?.color,
                  ),
                ),
              ],
            ),
            buildNotificationOption(
              "Notification",
              valNotify1,
              onChangeFunction1,
            ),
            buildNotificationOption(
              "Mise à jour",
              valNotify2,
              onChangeFunction2,
            ),
            SizedBox(height: 50),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/Icons/other.svg',
                  width: isPortrait ? 30 : 25,
                  height: isPortrait ? 40 : 35,
                  color: theme.iconTheme.color,
                ),
                SizedBox(width: 10),
                Text(
                  "Autre",
                  style: TextStyle(
                    fontSize: isPortrait ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyText1?.color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            buildNotificationOption(
              "Mode sombre",
              Provider.of<ThemeProvider>(context).isDarkMode,
                  (bool value) {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
              },
            ),
            buildCompteOptionWithDropdown(
              context,
              "Langue",
              selectedLanguage,
              ['Français', 'Anglais', 'Espagnol'],
                  (String? newValue) {
                setState(() {
                  selectedLanguage = newValue!;
                });
              },
            ),
            buildCompteOptionWithDropdown(
              context,
              "Région",
              selectedRegion,
              ['Afrique', 'Europe', 'Amérique', 'Asie'],
                  (String? newValue) {
                setState(() {
                  selectedRegion = newValue!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Padding buildNotificationOption(
      String title, bool value, Function(bool) onChangeMethod) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyText1?.color,
            ),
          ),
          Transform.scale(
            scale: 0.7,
            child: CustomCupertinoSwitch(
              value: value,
              onChanged: onChangeMethod,
              activeColor: Color.fromARGB(255, 10, 148, 116),
              inactiveColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector buildCompteOption(
      BuildContext context, String title, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyText1?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector buildCompteOptionWithDropdown(
      BuildContext context,
      String title,
      String selectedValue,
      List<String> options,
      ValueChanged<String?> onChanged,
      ) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyText1?.color,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(5),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedValue,
                onChanged: onChanged,
                items: options.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                underline: SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCupertinoSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color inactiveColor;

  CustomCupertinoSwitch({
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor,
      trackColor: inactiveColor,
    );
  }
}
