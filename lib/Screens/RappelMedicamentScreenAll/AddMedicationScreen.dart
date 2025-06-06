import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:medecineproject/BottomBar/BottomBarScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/medication.dart';
import 'DateTimePickerScreen.dart';
import 'AutoSuggestNameTextField.dart'; // Importez le nouveau widget
import 'dart:convert'; // Pour encoder et décoder JSON

class AddMedicationScreen extends StatefulWidget {
  final Medication? medication;

  AddMedicationScreen({this.medication});

  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late DateTime _date;
  late TimeOfDay _time;
  late String _notes;
  late String _repetition;
  late String? _audioPath; // Nouveau champ pour le chemin du fichier audio
  bool _notificationsEnabled = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, String> _categoryImages = {
    'Comprimé': 'assets/images/autres/categorieMedicament/comprime.png',
    'Sirop': 'assets/images/autres/categorieMedicament/sirop.png',
    'Injection': 'assets/images/autres/categorieMedicament/injection.png',
    'Pommade': 'assets/images/autres/categorieMedicament/pommade.png',
  };

  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _name = widget.medication!.name;
      _category = widget.medication!.category;
      _date = widget.medication!.date;
      _time = widget.medication!.time;
      _notes = widget.medication!.notes;
      _repetition = widget.medication!.repetition;
      _audioPath = widget.medication!.audioPath;
    } else {
      _name = '';
      _category = 'Comprimé';
      _date = DateTime.now();
      _time = TimeOfDay.now();
      _notes = '';
      _repetition = 'Jamais';
      _audioPath = null;
    }
    _nameController = TextEditingController(text: _name);
  }

  void _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac'],
    );

    if (result != null) {
      setState(() {
        _audioPath = result.files.single.path;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vous devez être connecté pour ajouter un rappel')),
        );
        return;
      }
      final newMedication = Medication(
        id: widget.medication?.id ?? _firestore.collection('Rappels').doc().id, // Generate ID if not editing
        name: _name,
        category: _category,
        date: _date,
        time: _time,
        repetition: _repetition,
        notes: _notes,
        audioPath: _audioPath,
        userId: user.uid, // Ajout de l'ID de l'utilisateur connecté
      );

      // Sauvegarder dans Firebase Firestore
      if (widget.medication == null) {
        await _firestore.collection('Rappels').doc(newMedication.id).set(newMedication.toMap());
      } else {
        await _firestore.collection('Rappels').doc(widget.medication!.id).update(newMedication.toMap());
      }

      // Sauvegarder dans SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? existingMedications = prefs.getString('medications');
      List<Map<String, dynamic>> medicationList = existingMedications != null
          ? List<Map<String, dynamic>>.from(json.decode(existingMedications))
          : [];
      medicationList.add(newMedication.toMap());
      prefs.setString('medications', json.encode(medicationList));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomBarScreen(initialIndex: 2)), // Navigate to BottomBarScreen with "Rappels" tab
            (Route<dynamic> route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.medication == null ? 'Médicament ajouté avec succès !' : 'Médicament modifié avec succès !')),
      );
    }
  }

  Future<void> _syncMedications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    QuerySnapshot snapshot = await _firestore.collection('Rappels').get();
    List<Medication> medications = snapshot.docs.map((doc) => Medication.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();

    List<Map<String, dynamic>> medicationList = medications.map((med) => med.toMap()).toList();
    prefs.setString('medications', json.encode(medicationList));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medication == null ? 'Ajouter un nouveau rappel' : 'Modifier le rappel',
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'Poppins-Medium',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nom du médicament',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00916E)),
              ),
              SizedBox(height: 8),
              SearchInput(
                textController: _nameController,
                hintText: 'Entrez le nom du médicament',
                onSelected: (String selectedName) {
                  setState(() {
                    _name = selectedName;
                  });
                },
              ),
              SizedBox(height: 16),
              Text(
                'Catégorie',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00916E)),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                items: _categoryImages.keys.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Row(
                      children: [
                        Image.asset(
                          _categoryImages[category]!,
                          width: 24,
                          height: 24,
                        ),
                        SizedBox(width: 8),
                        Text(category),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Catégorie',
                  filled: true,
                  fillColor: Color(0xFF199A8E).withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF00916E)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF00916E)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Date et heure',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00916E)),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Color(0xFFFFC107)),
                  SizedBox(width: 8),
                  Icon(Icons.access_time, color: Color(0xFFFF5722)),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DateTimePickerScreen(
                              onDateTimeSelected: (date, time, repetition) {
                                setState(() {
                                  _date = date ?? _date; // Assurez-vous de vérifier si date est null
                                  _time = time; // TimeOfDay est non-nullable dans DateTimePickerScreen
                                  _repetition = repetition ?? _repetition; // Assurez-vous de vérifier si repetition est null
                                });
                              },
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFF199A8E).withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Color(0xFF00916E)),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Détails',
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Notifications',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00916E)),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.notifications, color: Color(0xFFFF5722)),
                  SizedBox(width: 8),
                  Text('Activer les notifications'),
                  Spacer(),
                  Switch(
                    activeColor: Colors.white,
                    activeTrackColor: Colors.green,
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Notes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00916E)),
              ),
              SizedBox(height: 8),
              TextFormField(
                initialValue: _notes,
                decoration: InputDecoration(
                  hintText: 'Ajouter des notes sur le médicament',
                  filled: true,
                  fillColor: Color(0xFF199A8E).withOpacity(0.15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF00916E)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF00916E)),
                  ),
                ),
                maxLines: 4,
                onSaved: (value) {
                  _notes = value ?? ''; // Assurez-vous de vérifier si value est null
                },
              ),
              SizedBox(height: 16),
              // Nouveau bouton pour sélectionner le fichier audio
              Text(
                'Son de rappel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00916E)),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.music_note, color: Color(0xFF00916E)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _audioPath != null ? _audioPath! : 'Aucun fichier sélectionné',
                      style: TextStyle(color: Colors.black54),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _pickAudioFile,
                    child: Text('Sélectionner'),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00916E)),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(20),
                      backgroundColor: Color(0xFF00916E),
                    ),
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
