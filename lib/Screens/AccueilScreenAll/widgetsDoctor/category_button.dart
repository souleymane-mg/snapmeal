import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool isSelected;

  CategoryButton({required this.title, required this.onPressed, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InkWell(
        onTap: onPressed,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isSelected ? Color(0xFF1DBF73) : Color(0xFF1DBF73).withOpacity(0.2), // Vert similaire à l'image
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.white : Color(0xFF0EBE7F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
