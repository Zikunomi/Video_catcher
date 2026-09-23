import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ffmpeg_kit_flutter_new_min_gpl/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

enum DownloadType { youtube, hls, directMP4 }

class DownloadTask {
  final String id;
  final String title;
  final String url;
  final DownloadType type;
  double progress; //0.0 a 1.0
  String status; // 'Descargado', 'Completado', "Error"

  DownloadTask({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    this.progress = 0.0,
    this.status = 'Pendiente',
  });
}

class DownloadDispatcher {
  static DownloadType detectType(String url) {
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return DownloadType.youtube;
    } else if (url.contains('.m3u8') || url.contains('.mpd')) {
      return DownloadType.hls;
    } else {
      return DownloadType.directMP4;
    }
    }


static Future<void> startDownload({
  required DownloadTask task,
  required Map<String, String> headers,
  required Function(double progress, String status) onUpdate,
}) async {
  Directory dir = await getApplicationDocumentsDirectory();
  String savePath = '${dir.path}/${task.title}.mp4';
  
  switch (task.type) {
    case DownloadType.youtube:
      var yt = YoutubeExplode();
      try {
        var video = await yt.videos.get(task.url);
        var manifest = await yt.videos.streamsClient.getManifest(video.id);
        var streamInfo = manifest.muxed.withHighestBitrate();
        
        var stream = yt.videos.streamsClient.get(streamInfo);
        var file = File(savePath);
        var fileStream = file.openWrite();

        int dowloaded = 0;
        int total = streamInfo.size.totalBytes;

        await stream.forEach((data) {
          dowloaded += data.length;
          fileStream.add(data);
          double progress = dowloaded / total;
          onUpdate(progress, 'Descargando desde youtube...');
        });

        await fileStream.close();
        onUpdate(1.0, 'Completado');
      } finally {
        yt.close();
      }
      break;

      case DownloadType.directMP4:
        Dio dio = Dio();
        await dio.download(
          task.url,
          savePath,
          options: Options(headers: headers),
          onReceiveProgress: (received, total) {
            if (total != -1) {
              onUpdate(received / total, 'Descargando video...');
            }
          },
        );
        onUpdate(1.0, 'Completado');
        break;

      case DownloadType.hls:
        String headersOption = '';
        if (headers.isNotEmpty) {
          String hStr = headers.entries.map((e) => '${e.key}: ${e.value}').join('\r\n');
          headersOption = '-headers "$hStr\r\n"';
        }

        String command = '$headersOption -i "${task.url}" -c copy "$savePath"';

        await FFmpegKit.executeAsync(command, (session) async {
          onUpdate(1.0, 'Completado');
        }, (log) {}, (stats) {
          onUpdate(0.5, 'Descargando video...');
        });
        break;  
  }}}