import 'package:flutter/material.dart';

PreferredSizeWidget customAppBar({
  required String title,
  required IconData leadingIcon,
  VoidCallback? onLeadingPressed,
}) {
  return AppBar(
    backgroundColor: const Color(0xFFFFC800),
    titleTextStyle: const TextStyle(
      color: Colors.black,
      fontSize: 22,
      fontFamily: 'BrandonGrotesque',
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
    centerTitle: true,
    title: Text(title),
    leading: IconButton(
      icon: Icon(leadingIcon, size: 30, color: Colors.black),
      onPressed: onLeadingPressed,
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Image.asset("images/Copie de Logo noir.png", width: 45),
      ),
    ],
    elevation: 4,
    shadowColor: Colors.black.withOpacity(0.3),
  );
}
