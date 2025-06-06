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
      return data['nom_pr'] as String;
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
      onSelected: (String? selectedOption) {
        setState(() {
          widget.textController.text = selectedOption ?? '';
        });
        if (selectedOption != null) {
          widget.onSelected(selectedOption);
        }
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                offset: const Offset(12, 26),
                blurRadius: 50,
                spreadRadius: 0,
                color: Colors.grey.withOpacity(.1)),
          ]),
          child: TextField(
            controller: textEditingController,
            focusNode: focusNode,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Color(0xff4338CA)),
              filled: true,
              fillColor: Colors.white,
              hintText: widget.hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
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
