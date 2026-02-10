import 'package:flutter/material.dart';
import 'package:jonssony/utils/app_text.dart';

Widget Custom_AppBar(BuildContext context, String title) {
  return Padding(

    padding: EdgeInsets.only(
      top: MediaQuery.of(context).padding.top + 10,
      left: 10,
      bottom: 10,
    ),
    child: Row(
      children: [
        // Back Button
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E3E32)),
          onPressed: () => Navigator.pop(context),
        ),

        AppText(
          title,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2E3E32),
        ),
      ],
    ),
  );
}