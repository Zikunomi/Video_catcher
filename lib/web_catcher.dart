import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

Future<void> downLoadWebVideo(String videoUrl, Function(int, int) onProgress) async {

 Dio dio = Dio();
  try {
    // Obtener el directorio de documentos de la aplicación
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String savePath = '${appDocDir.path}/video.mp4';

    // Descargar el video y escribirlo en el archivo
    await dio.download(
      videoUrl,
      savePath,
      onReceiveProgress: (received, total) {
        if (total != -1) {
          double progress = (received / total) * 100;
          onProgress(received, total);
          print('Progreso de descarga: ${progress.toStringAsFixed(0)}%');
        }
      },
    );
    print('Video descargado en: $savePath');
  } catch (e) {
    print('Error al descargar el video: $e');
  }
}