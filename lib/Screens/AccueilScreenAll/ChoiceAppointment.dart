import 'package:flutter/material.dart';


class ChoiceAppointment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Retours'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppointmentOption(
              imagePath: 'assets/images/autres/ImagesAccueil/medecin.png',
              title: 'Consultation à domicile',
              description: 'Des soins médicaux personnalisés dans le confort de votre foyer.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MakingAppointment()),
                );
              },
            ),
            SizedBox(height: 20),
            AppointmentOption(
              imagePath: 'assets/images/autres/ImagesAccueil/hopital.png',
              title: 'Consultation à l’hopital',
              description: 'Services médicaux complets dans notre établissement de pointe.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MakingAppointment()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentOption extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;
  final VoidCallback onTap;

  AppointmentOption({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 100,
              ),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MakingAppointment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Retours'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DoctorCard(),
            SizedBox(height: 20),
            DaySelector(),
            SizedBox(height: 20),
            Text(
              'Mardi, 16 juillet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Matiné',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TimeSlotRow(slots: ['06:00-08:30', '08:00-10:30', '10:00-12:30']),
            SizedBox(height: 20),
            Text(
              'Après midi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TimeSlotRow(slots: ['12:00-13:30', '13:30-15:30', '15:30-17:30', '17:30-19:30', '21:00-22:00']),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
                    child: Text(
                      'Annuler',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 30.0),
                    child: Text(
                      'Valider',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/images/autres/ImagesAccueil/medecin.png'), // Remplacez par l'URL ou l'asset correct
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr. Stefi Jessi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Orthopedist'),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star, color: Colors.amber, size: 16),
                    Icon(Icons.star_half, color: Colors.amber, size: 16),
                  ],
                )
              ],
            ),
            Spacer(),
            Icon(Icons.favorite, color: Colors.red),
          ],
        ),
      ),
    );
  }
}

class DaySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        DayButton(day: 'Lundi', isSelected: false),
        DayButton(day: 'Mardi', isSelected: true),
        DayButton(day: 'Mercredi', isSelected: false),
      ],
    );
  }
}

class DayButton extends StatelessWidget {
  final String day;
  final bool isSelected;

  DayButton({required this.day, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor: isSelected ? Colors.green : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.green),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Text(
          day,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

class TimeSlotRow extends StatelessWidget {
  final List<String> slots;

  TimeSlotRow({required this.slots});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: slots.map((slot) {
        bool isAvailable = !slot.contains('06:00-08:30') && !slot.contains('12:00-13:30') && !slot.contains('15:30-17:30');
        return TimeSlotButton(
          time: slot,
          isAvailable: isAvailable,
        );
      }).toList(),
    );
  }
}

class TimeSlotButton extends StatelessWidget {
  final String time;
  final bool isAvailable;

  TimeSlotButton({required this.time, required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        backgroundColor: isAvailable ? Colors.green : Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
        child: Text(
          time,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
