import 'package:flutter/material.dart';

Widget Custom_Libary_Bg() {
  return Stack(
    children: [
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: 180,
        child: Image.asset(
          'assets/images/my_emdr.png',
          fit: BoxFit.fill,
        ),
      ),


      Positioned.fill(
        child: Container(
          margin: const EdgeInsets.only(top: 100),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
            image: DecorationImage(
              image: AssetImage('assets/images/bg_library.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),


      Positioned.fill(
        child: Container(
          margin: const EdgeInsets.only(top: 150),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(35),
              topRight: Radius.circular(35),
            ),
          ),
        ),
      ),
    ],
  );
}