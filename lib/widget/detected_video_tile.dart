import 'package:flutter/material.dart';
import 'package:Video_catcher/models/detected_video.dart';

class DetectedVideoTile extends StatelessWidget{

  final DetectedVideo video;
  final VoidCallback onDownload;

  const DetectedVideoTile({
    super.key,
    required this.video,
    required this.onDownload
});

@override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        video.type.contains('HLS')
          ? Icons.stream
          : Icons.movie,
        color: Colors.indigoAccent,
      ),
      title: Text(
        video.url,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.download),
        color: Colors.green,
        onPressed: onDownload,
      ),
    );
  }
}