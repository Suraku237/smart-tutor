import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
   home:Scaffold(

    backgroundColor:  const Color.fromARGB(255, 130, 53, 133),
  
    body:Container(
   decoration: const BoxDecoration(
    image:DecorationImage(
      image: AssetImage('Assert/home.png'),
     fit:BoxFit.cover,
      ),
      
   ),
    ),
   ),
 );
    
  }
}