import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  if (Platform.isAndroid || Platform.isIOS){
    await[
    Permission.storage,
    Permission.videos
    ].request();
  }
}