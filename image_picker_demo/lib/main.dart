import 'package:flutter/material.dart';
import 'custom_image_picker.dart';

void main()=>runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:'BottomNavigationBar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
         primarySwatch: Colors.lightBlue
      ),
      home: CustomImagePicker(title: "照片,视频"),
    );
  }
}