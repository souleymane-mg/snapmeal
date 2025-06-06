import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../models/medication.dart';
import 'DateTimePickerScreen.dart';

class DetailMedicamentSelectionner extends StatefulWidget {
  final Medication medication;

  DetailMedicamentSelectionner({required this.medication});

  @override
  _DetailMedicamentSelectionnerState createState() => _DetailMedicamentSelectionnerState();
}

class _DetailMedicamentSelectionnerState extends State<DetailMedicamentSelectionner> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late DateTime _date;
  late TimeOfDay _time;
  late String _notes;
  late String _repetition;
  late String? _audioPath; // Nouveau champ pour le chemin du fichier audio
  bool _notificationsEnabled = true;
  bool _isEditing = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map<String, String> _categoryImages = {
    'Comprimé': 'assets/images/autres/categorieMedicament/comprime.png',
    'Sirop': 'assets/images/autres/categorieMedicament/sirop.png',
    'Injection': 'assets/images/autres/categorieMedicament/injection.png',
    'Pommade': 'assets/images/autres/categorieMedicament/pommade.png',
  };

  @override
  void initState() {
    super.initState();
    _name = widget.medication.name;
    _category = widget.medication.category;
    _date = widget.medication.date;
    _time = widget.medication.time;
    _notes = widget.medication.notes;
    _repetition = widget.medication.repetition;
    _audioPath = widget.medication.audioPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier le rappel' : 'Détails du médicament'),
        actions: [
          if (!_isEditing)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
                Text(
                  'Modifier',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          if (_isEditing)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _deleteMedication,
                ),
                Text(
                  'Supprimer',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Nom du médicament', _name, (value) => _name = value, !_isEditing),
              SizedBox(height: 16),
              _buildDropdownField('Catégorie', _category, (value) => _category = value!, !_isEditing),
              SizedBox(height: 16),
              _buildDateTimePicker(),
              SizedBox(height: 16),
              _buildNotificationsToggle(),
              SizedBox(height: 16),
              _buildTextField('Notes', _notes, (value) => _notes = value, !_isEditing, maxLines: 4),
              SizedBox(height: 16),
              _buildAudioPicker(),
              if (_isEditing) SizedBox(height: 16),
              if (_isEditing) _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue, Function(String) onSaved, bool readOnly, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00916E)),
        ),
        SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            hintText: label,
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
          readOnly: readOnly,
          maxLines: maxLines,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer $label';
            }
            return null;
          },
          onSaved: (value) {
            onSaved(value!);
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String initialValue, Function(String?) onChanged, bool readOnly) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00916E)),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: initialValue,
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
          onChanged: readOnly ? null : onChanged,
          decoration: InputDecoration(
            hintText: label,
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
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                onPressed: !_isEditing ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DateTimePickerScreen(
                        onDateTimeSelected: (date, time, repetition) {
                          setState(() {
                            _date = date ?? _date;
                            _time = time;
                            _repetition = repetition ?? _repetition;
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
                      '${_date.day}/${_date.month}/${_date.year} ${_time.format(context)}',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationsToggle() {
    return Row(
      children: [
        Icon(Icons.notifications, color: Color(0xFFFF5722)),
        SizedBox(width: 8),
        Text('Activer les notifications'),
        Spacer(),
        Switch(
          activeColor: Colors.white,
          activeTrackColor: Colors.green,
          value: _notificationsEnabled,
          onChanged: !_isEditing ? null : (value) {
            setState(() {
              _notificationsEnabled = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAudioPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              onPressed: !_isEditing ? null : _pickAudioFile,
              child: Text('Sélectionner'),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00916E)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Padding(
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
    );
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
          SnackBar(content: Text('Vous devez être connecté pour modifier un rappel')),
        );
        return;
      }
      final updatedMedication = Medication(
        id: widget.medication.id,
        name: _name,
        category: _category,
        date: _date,
        time: _time,
        repetition: _repetition,
        notes: _notes,
        audioPath: _audioPath,
        userId: user.uid, // Ajout de l'ID de l'utilisateur connecté
      );

      await _firestore.collection('Rappels').doc(updatedMedication.id).update(updatedMedication.toMap());

      // Mise à jour dans SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? existingMedications = prefs.getString('medications');
      List<Map<String, dynamic>> medicationList = existingMedications != null
          ? List<Map<String, dynamic>>.from(json.decode(existingMedications))
          : [];
      medicationList.removeWhere((med) => med['id'] == updatedMedication.id);
      medicationList.add(updatedMedication.toMap());
      prefs.setString('medications', json.encode(medicationList));

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Médicament modifié avec succès !')),
      );
    }
  }

  void _deleteMedication() async {
    await _firestore.collection('Rappels').doc(widget.medication.id).delete();

    // Suppression de SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? existingMedications = prefs.getString('medications');
    if (existingMedications != null) {
      List<Map<String, dynamic>> medicationList = List<Map<String, dynamic>>.from(json.decode(existingMedications));
      medicationList.removeWhere((med) => med['id'] == widget.medication.id);
      prefs.setString('medications', json.encode(medicationList));
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Médicament supprimé avec succès !')),
    );
  }
}
