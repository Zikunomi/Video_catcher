import 'package:Video_catcher/mainAppShell.dart';
import 'package:flutter/material.dart';
import 'package:Video_catcher/permission.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();


  requestPermissions();
  
  runApp(const Video_catcher());
}

class Video_catcher extends StatelessWidget {
  const Video_catcher({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'Video Catcher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const MainAppShell(),
      );
  }
}