import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<void> downloadVideo(String videoUrl) async {
  var yt = YoutubeExplode();
  try{
  //Obtener los metadatos del video
  var video = await yt.videos.get(videoUrl);
  var manifest = await yt.videos.streamsClient.getManifest(video.id);

  // Obtener el audio de mejor calidad
  var streamInfo = manifest.muxed.withHighestBitrate();

  // Get the application documents directory
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String filePath = '${appDocDir.path}/${video.title}.mp4';

  // Crear el archivo de salida y el flujo de escritura y gaurdar en su carpeta
  var file = File(filePath);
  var stream = yt.videos.streamsClient.get(streamInfo);
  var output = file.openWrite();

  // Descargar el video y escribirlo en el archivo
  await stream.pipe(output);
  await output.flush();
  await output.close();
  print('Video descargado en: $filePath');
  } catch (e) {
    print('Error al descargar el video: $e');
  } finally {
    yt.close();
  }
}