import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:medecineproject/Screens/AccueilScreenAll/AccueilScreen.dart';
import 'package:medecineproject/Screens/RendezVousScreenAll/calendrier.dart';
import 'package:medecineproject/Screens/RappelMedicamentScreenAll/RappelMedicamentScreen.dart';
import 'package:medecineproject/Screens/ProfillScreenAll/ProfilUserScreen.dart';

class BottomBarScreen extends StatefulWidget {
  final int initialIndex;

  BottomBarScreen({this.initialIndex = 0});

  @override
  _BottomBarScreenState createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final _screens = [
    AccueilScreen(),
    ScheduleScreen(),
    RappelMedicamentScreen(),
    ProfilUserScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Désactiver l'animation
        showSelectedLabels: true, // Toujours afficher les libellés pour les éléments sélectionnés
        showUnselectedLabels: true, // Toujours afficher les libellés pour les éléments non sélectionnés
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/Icons/Home.svg',
              color: _selectedIndex == 0 ? Color(0xFF00916E) : Color(0xFF002B20),
            ),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/Icons/Calendar.svg',
              color: _selectedIndex == 1 ? Color(0xFF00916E) : Color(0xFF002B20),
            ),
            label: 'Rendez-Vous',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/Icons/Medoc.svg',
              color: _selectedIndex == 2 ? Color(0xFF00916E) : Color(0xFF002B20),
            ),
            label: 'Rappels',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/Icons/user.svg',
              color: _selectedIndex == 3 ? Color(0xFF00916E) : Color(0xFF002B20),
            ),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF00916E),
        onTap: _onItemTapped,
      ),
    );
  }
}
