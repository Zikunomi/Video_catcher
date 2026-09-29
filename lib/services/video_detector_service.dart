import 'package:Video_catcher/models/detected_video.dart';

class VideoDetectorService {
  DetectedVideo? processUrl(
    String url, {
    Map<String, String> headers = const {},
    }) {
      if (url.isEmpty){
        return null;
      }

    String type = 'MP4';

    final lowerUrl = url.toLowerCase();

    if (lowerUrl.contains('.m3u8')){
      type = 'HLS (.m3u8)';
    } else if (lowerUrl.contains('.mpd')){
      type = 'DASH (.mpd)';
    } else if (lowerUrl.contains('.webm')) {
      type = 'WEBM';
    }

    return DetectedVideo(
      url: url,
      type: type,
      headers: headers);
    }
}