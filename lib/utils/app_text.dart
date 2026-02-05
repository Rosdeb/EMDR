import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppText(
      this.text, {
        super.key,
        this.color,
        this.fontSize,
        this.fontWeight,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        letterSpacing: 0.2,
        fontSize: fontSize ?? 20,
        fontFamily:'Serif',
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color ?? Colors.black,
      ),
    );
  }
}
