import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/return_code.dart';

Future<void> downloadHLSVideo({
  required String m3u8Url,
  required String fileName,
  Map<String, String>? headers,
  Function(StringStatus status)? onStatusChange,
}) async {
  // Obtener el directorio de documentos de la aplicación
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String savePath = '${appDocDir.path}/$fileName.mp4';

  //Si el archivo ya existe, eliminarlo para evitar problemas de sobrescritura
  File outputFile = File(savePath);
  if (await outputFile.exists()) {
    await outputFile.delete();
  }
  //Construir los encabezados HTTP si la web requiere autenticación o encabezados personalizados
  String headersOption = '';
  if (headers != null && headers.isNotEmpty) {
    String headersString = headers.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\r\n');
    headersOption = '-headers "$headersString\r\n"';
  }

  // Construir el comando FFmpeg para descargar y convertir el video HLS a MP4
  String command = '$headersOption-i "$m3u8Url" -c copy "$savePath"';
  print('Ejecutando comando FFmpeg: $command');

  // Ejecutar el comando FFmpeg
  await FFmpegKit.executeAsync(
    command,
    (session) async {
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        print('Video descargado en: $savePath');
      } else if (ReturnCode.isCancel(returnCode)) {
        print('Descarga cancelada');
      } else {
        final failStackTrace = await session.getFailStackTrace();
        print('Error al descargar el video: $failStackTrace');
      }
    },
    (log) {
      //Registra la salide en tiempo real de FFmpeg
      print(log.getMessage());
    },
    (statistics) {
      //Puedes calcular el progreso de la descarga si es necesario
      print('Progreso: ${statistics.getTime()} ms');
    },
  );
}

enum StringStatus { downloading, completed, error }
