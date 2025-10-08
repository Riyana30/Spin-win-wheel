import 'dart:async';

import 'package:flutter/material.dart';
import 'package:luckyturn/spin.dart';

class spalsh extends StatefulWidget {
  spalsh({super.key});
  @override
  State<spalsh> createState() => _splashscreen();
}

class _splashscreen extends State<spalsh> {
  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
      () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SpinWheel()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart,
              size: 100,
              color: Color.fromARGB(255, 46, 25, 142),
            ),
            SizedBox(height: 10),
            Text(
              "Lucky Turn",
              style: TextStyle(
                color: Color.fromARGB(255, 46, 25, 142),
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: 'IrishGrover',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
