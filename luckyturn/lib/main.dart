import 'package:flutter/material.dart';
import 'package:luckyturn/spin.dart';
import 'package:luckyturn/splash.dart';

void main(){
  runApp(MaterialApp(debugShowCheckedModeBanner: false,
  initialRoute: '/',
  routes: {
    '/':(context)=>spalsh(),
      '/login':(context)=>SpinWheel(),
  },));
}