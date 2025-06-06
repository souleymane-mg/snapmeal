import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class PharmacyMapScreen extends StatefulWidget {
  @override
  _PharmacyMapScreenState createState() => _PharmacyMapScreenState();
}

class _PharmacyMapScreenState extends State<PharmacyMapScreen> with TickerProviderStateMixin {
  Position? _currentPosition;
  List<Map<String, dynamic>> pharmacies = [];
  List<Map<String, dynamic>> displayedPharmacies = [];
  late final MapController _mapController;
  TextEditingController _searchController = TextEditingController();
  List<String> _medicationOptions = [];
  List<String> _filteredMedicationOptions = [];

  LatLng? _initialCenter;
  double? _initialZoom;
  Map<String, dynamic>? _focusedPharmacy;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
    _checkLocationPermission();
    _fetchMedications();
    _fetchMedicationNames();
    _searchController.addListener(_handleSearch);
  }

  _handleSearch() {
    setState(() {
      if (_searchController.text.isEmpty) {
        displayedPharmacies = pharmacies;
        _filteredMedicationOptions = [];
        _resetZoom();
      } else {
        _filterMedications(_searchController.text);
        _filteredMedicationOptions = _medicationOptions
            .where((option) => option.toLowerCase().startsWith(_searchController.text.toLowerCase()))
            .take(1)
            .toList();
      }
    });
  }

  _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
      });
      print("Position actuelle: $_currentPosition");
    } catch (e) {
      print("Erreur lors de l'obtention de la position : $e");
    }
  }

  Future<void> _fetchMedications() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore.collection('stock_medicament').get();
    List<Map<String, dynamic>> medications = querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

    List<Map<String, dynamic>> pharmacyDetails = [];
    for (var med in medications) {
      String pharmacyId = med['id_phr_stck'];
      DocumentSnapshot pharmacySnapshot = await firestore.collection('pharmacie_phr').doc(pharmacyId).get();
      if (pharmacySnapshot.exists) {
        var pharmacie = pharmacySnapshot.data() as Map<String, dynamic>;
        var medicament = med['id_mdc_stck'];
        if (pharmacie != null && medicament != null) {
          var pharmacyLocation = {
            'nom_phr': pharmacie['nom_phr'],
            'lat': pharmacie['lat'],
            'lon': pharmacie['lon'],
            'horairesOuverture_phr': pharmacie['horairesOuverture_phr'],
            'horairesFermeture_phr': pharmacie['haoraireFermeture_phr'],
            'medicament': {
              'nom_mdc': medicament['nom_mdc'],
              'dosage_mdc': medicament['dosage_mdc'],
              'quantite_stck': med['quantite_stck']
            }
          };
          pharmacyDetails.add(pharmacyLocation);
        }
      }
    }

    setState(() {
      pharmacies = pharmacyDetails;
      displayedPharmacies = pharmacies;
    });
  }

  Future<void> _fetchMedicationNames() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore.collection('medicament_mdc').get();
    List<String> medicationNames = querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return data['nom_mdc'] as String;
    }).toList();

    setState(() {
      _medicationOptions = medicationNames;
    });
  }

  void _filterMedications(String searchQuery) {
    setState(() {
      displayedPharmacies = pharmacies.where((pharmacy) {
        var med = pharmacy['medicament'];
        var medName = med['nom_mdc'];
        return medName != null && medName.toLowerCase().startsWith(searchQuery.toLowerCase());
      }).toList();

      if (displayedPharmacies.isEmpty) {
        _focusedPharmacy = null;
      }
    });

    // Centre la carte sur la pharmacie la plus proche après filtrage
    if (displayedPharmacies.isNotEmpty) {
      _focusOnClosestPharmacy();
    } else {
      _resetZoom();
    }
  }

  void _focusOnClosestPharmacy() {
    if (_currentPosition == null) return;

    double minDistance = double.infinity;
    Map<String, dynamic>? closestPharmacy;

    for (var pharmacy in displayedPharmacies) {
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        pharmacy['lat'],
        pharmacy['lon'],
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestPharmacy = pharmacy;
      }
    }

    if (closestPharmacy != null) {
      setState(() {
        _focusedPharmacy = closestPharmacy;
      });
      LatLng closestLatLng = LatLng(closestPharmacy['lat'], closestPharmacy['lon']);
      _animatedMoveToLocation(closestLatLng, 15.0);
    }
  }

  void _animatedMoveToLocation(LatLng latLng, double zoom) {
    _initialCenter ??= _mapController.center;
    _initialZoom ??= _mapController.zoom;

    var currentZoom = _mapController.zoom;
    var latTween = Tween<double>(begin: _mapController.center.latitude, end: latLng.latitude);
    var lngTween = Tween<double>(begin: _mapController.center.longitude, end: latLng.longitude);
    var zoomTween = Tween<double>(begin: currentZoom, end: zoom);

    var controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    var animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)), zoomTween.evaluate(animation));
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _resetZoom() {
    if (_initialCenter != null && _initialZoom != null) {
      _animatedMoveToLocation(_initialCenter!, _initialZoom!);
      setState(() {
        _focusedPharmacy = null;
      });
    }
  }

  _launchMaps(double lat, double lon) async {
    if (_currentPosition != null) {
      final url = 'https://www.google.com/maps/dir/?api=1&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&destination=$lat,$lon&travelmode=driving';
      print('Navigating to URL: $url'); // Pour déboguer et vérifier l'URL
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $uri';
      }
    } else {
      print('Current position is null');
    }
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        // Les permissions sont refusées, gérer ce cas
        print('Permissions de localisation refusées');
        return;
      }
    }
    // Permissions accordées
    _getCurrentLocation();
  }

  void _showPharmacyDetails(Map<String, dynamic> pharmacy) {
    String nom_phr = pharmacy['nom_phr'];
    double lat = pharmacy['lat'];
    double lon = pharmacy['lon'];
    String? horairesOuverture = pharmacy['horairesOuverture_phr'];
    String? horairesFermeture = pharmacy['horairesFermeture_phr'];


    if (horairesOuverture == null || horairesFermeture == null) {
      // Handle the error case where the opening or closing hours are null
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Les horaires d\'ouverture ou de fermeture ne sont pas disponibles.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    String horaires = "Ouvre de : $horairesOuverture H à $horairesFermeture H";

    try {
      // Parsing des heures d'ouverture et de fermeture
      DateTime now = DateTime.now();
      DateFormat dateFormat = DateFormat('H:mm');
      DateTime ouverture = dateFormat.parse(horairesOuverture);
      DateTime fermeture = dateFormat.parse(horairesFermeture);

      // Convertir les heures d'ouverture et de fermeture en DateTime aujourd'hui
      DateTime ouvertureToday = DateTime(now.year, now.month, now.day, ouverture.hour, ouverture.minute);
      DateTime fermetureToday = DateTime(now.year, now.month, now.day, fermeture.hour, fermeture.minute);

      // Ajuster les heures de fermeture pour le cas où elles seraient après minuit
      if (fermetureToday.isBefore(ouvertureToday)) {
        fermetureToday = fermetureToday.add(Duration(days: 1));
      }

      // Vérifier si la pharmacie est ouverte ou fermée
      bool isOpen = now.isAfter(ouvertureToday) && now.isBefore(fermetureToday);
      String statut = isOpen ? "Actuellement ouvert" : "Actuellement fermé";
      Color statutColor = isOpen ? Colors.green : Colors.red;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(
                  children: [
                    SvgPicture.asset(
                      'assets/images/autres/ImagesAccueil/pharmacy2.svg', // Chemin de l'image SVG
                      width: MediaQuery.of(context).size.width - 40, // Ajuster pour le padding
                      fit: BoxFit.contain,
                      placeholderBuilder: (BuildContext context) => Container(
                        padding: const EdgeInsets.all(30.0),
                        child: const CircularProgressIndicator(), // Afficher un indicateur de chargement si l'image ne peut pas être chargée
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            horaires, // Afficher les horaires formatés
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black45,
                              backgroundColor: Colors.white.withOpacity(0.7), // Ajouter un fond blanc transparent pour améliorer la lisibilité
                            ),
                          ),
                          Text(
                            statut, // Afficher le statut
                            style: TextStyle(
                              fontSize: 16,
                              color: statutColor,
                              backgroundColor: Colors.white.withOpacity(0.7), // Ajouter un fond blanc transparent pour améliorer la lisibilité
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        nom_phr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.directions, size: 24),
                      label: Text('Obtenir l\'itinéraire'),
                      onPressed: () {
                        Navigator.of(context).pop(); // Fermer le BottomSheet avant de lancer l'itinéraire
                        _launchMaps(lat, lon);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Couleur du bouton
                        foregroundColor: Colors.white, // Couleur de l'icône et du texte
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Voulez-vous obtenir l\'itinéraire?',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      print("Erreur de parsing des horaires : $e");
      // Afficher un message d'erreur à l'utilisateur
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Format des horaires incorrect : $horairesOuverture à $horairesFermeture'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche de médicaments',
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'Poppins-Medium',
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Color(0xff4338CA)),
                    filled: true,
                    fillColor: Colors.grey[200],
                    hintText: 'Saisissez ici le nom du médicament',
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                  ),
                ),
                if (_filteredMedicationOptions.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredMedicationOptions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_filteredMedicationOptions[index]),
                          onTap: () {
                            _searchController.text = _filteredMedicationOptions[index];
                            _filterMedications(_filteredMedicationOptions[index]);
                            _filteredMedicationOptions = [];
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: LatLng(12.616117, -7.982478), // Centre initial à Bamako
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: displayedPharmacies.map((pharmacy) {
                    bool isFocused = pharmacy == _focusedPharmacy;
                    return Marker(
                      point: LatLng(pharmacy['lat'], pharmacy['lon']),
                      width: isFocused ? 100 : 80,
                      height: isFocused ? 100 : 80,
                      builder: (ctx) => GestureDetector(
                        onTap: () {
                          _showPharmacyDetails(pharmacy);
                        },
                        child: Tooltip(
                          message: pharmacy['nom_phr'],
                          child: Icon(
                            Icons.location_pin,
                            color: isFocused ? Colors.blue : Colors.red,
                            size: isFocused ? 50.0 : 40.0,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PharmacyMapScreen(),
  ));
}
