import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchInput extends StatefulWidget {
  final TextEditingController textController;
  final String hintText;
  final Function(String) onSelected;

  const SearchInput({Key? key, required this.textController, required this.hintText, required this.onSelected}) : super(key: key);

  @override
  _SearchInputState createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  List<String> _options = [];

  @override
  void initState() {
    super.initState();
    _fetchMedicationNames();
  }

  Future<void> _fetchMedicationNames() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot = await firestore.collection('produit_pr').get();
    List<String> medicationNames = querySnapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      String name = data['nom_pr'] ?? 'Unknown'; // Vérification de nullité
      String dosage = data['dosage_pr'] ?? 'Unknown'; // Vérification de nullité
      String type = data['type_pr'] ?? 'Unknown'; // Vérification de nullité
      return '$name - $dosage ($type)';
    }).toList();

    setState(() {
      _options = medicationNames;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return _options.where((String option) {
          return option.toLowerCase().startsWith(textEditingValue.text.toLowerCase());
        }).take(3);
      },
      onSelected: (String selectedOption) {
        setState(() {
          widget.textController.text = selectedOption;
        });
        widget.onSelected(selectedOption);
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: widget.hintText,
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
            prefixIcon: const Icon(Icons.add, color: Color(0xFF00916E)), // Remplace l'icône de recherche par une icône de +
          ),
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: SizedBox(
              height: 200,
              width: 255,
              child: ListView(
                padding: EdgeInsets.zero,
                children: options.map((String option) {
                  return ListTile(
                    title: Text(option),
                    onTap: () {
                      onSelected(option);
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
